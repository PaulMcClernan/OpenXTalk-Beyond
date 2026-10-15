#!/usr/bin/env python3
# Copyright (C) 2026 OXT-Beyond contributors.
#
# This file is part of OXT-Beyond.
#
# OXT-Beyond is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License v3 as published by the Free
# Software Foundation.
#
# OXT-Beyond is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License
# along with OXT-Beyond.  If not see <http://www.gnu.org/licenses/>.

"""Run the LiveCode Script tests of tests/lcs in the web engine, in a
headless browser, and compare the failures with a baseline of known ones.

  python3 tools/ci/web_tests.py --runtime DIR --bin DIR [--engine FILE]
      [--filter REGEX] [--work DIR] [--timeout SECONDS] [--retries N]
      [--baseline FILE] [--update-baseline] [--log FILE]

--runtime is the web runtime, as for tools/ci/web_check.py, and --bin the
build output of a desktop build of the same checkout (linux-x86_64-bin):
its lc-compile compiles the LiveCode Builder modules that the tests load
to _tests/_build in the checkout, as tools/ci/run_engine_tests.py does;
its development engine (or --engine) makes the standalone's startup data,
as web_check.py does with --runtime; and its packaged_extensions have the
extensions that the tests load (TestLoadExtension).

The standalone's main stack is tools/ci/web-tests.livecodescript, which
runs the tests one after the other in the one engine, with the test
runner's set-up and clean-up (tests/_testrunnerbehavior.livecodescript),
as LiveCode's standalone test runner (tests/_standalonetestrunner) runs
them; in a desktop run each test has an engine of its own. Its stack is
named as that runner's, which tells the test library that it runs in a
standalone: the tests that need the IDE, the documentation, the LiveCode
Builder compiler or externals skip there, and in the web engine those
that need sockets or other programs (the test library's requirements
"sockets" and "shell"), which a page cannot have. The standalone has, in
/boot/standalone (specialFolderPath("resources")), what the tests read
from the checkout: tests/, the modules compiled to _tests/_build, the
engine's lists of errors (the test library names errors from
engine/src/executionerrors.h) and the scripts of the checkout that tests
load (their paths are found in the tests: TestGetEngineRepositoryPath()
& "/<path>"); and in /boot/packaged_extensions the extensions, where the
test library looks for them (next to an engine folder,
specialFolderPath("engine") is /boot).

The tests are the "on Test..." handlers of tests/lcs, as
run_engine_tests.py finds them, and each has its result as there: its
worst TAP result, and FAIL when it does not end within --timeout seconds,
quits (which the runner cancels) or stops the engine. The page is then
opened again to go on with the next test. The page's dialogs, which
answer and ask show, are answered with their default buttons.

The failures are looked up in the baseline, tools/ci/web-tests-baseline.txt
(lines as run_engine_tests.py's baselines have them: "lcs: <test>", "? "
before one that fails only sometimes, comments after " #"). A failure not
in it is run again on its own, in a page of its own (--retries, default
once): when it passes then, it is reported as flaky (it depends on what
the tests before it left behind) and does not fail the check; else it is
new, and fails the check. Baseline entries that passed are reported, so
that they can be removed. --update-baseline rewrites the baseline with the
failures, keeping the comments of the entries that it had.

The log (--log, default <work>/web-tests.log) has every failed test's
output, with what the browser's console said during it. Under GitHub
Actions a summary goes to the job summary. Exit status: 0 when no test
failed that is not in the baseline, 1 when one did, 2 when the tests could
not be run. Needs Python 3.8 or later and the Python package playwright
with its Chromium (python3 -m playwright install chromium).
"""

import argparse
import os
import re
import shutil
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import run_engine_tests  # noqa: E402
import web_check  # noqa: E402
from run_engine_tests import RESULT_ORDER, Result, analyse_tap, outcome_of  # noqa: E402
from web_check import CheckError, log  # noqa: E402

REPO = web_check.REPO
RUNNER_SCRIPT = os.path.join(HERE, 'web-tests.livecodescript')
BASELINE = os.path.join(HERE, 'web-tests-baseline.txt')
TITLE = 'Web Tests'

# The engine's lists of errors, from which the test library names the
# errors that a test expects (TestBuildErrorMap)
ERROR_FILES = ('engine/src/executionerrors.h', 'engine/src/parseerrors.h')

# The comment at the top of the baseline, which --update-baseline writes
BASELINE_HEADER = (
    '# Web test suite (tools/ci/web_tests.py): LiveCode Script tests known to\n'
    '# fail in the web engine, run in a web standalone in a headless browser.\n'
    '# One "lcs: <test>" per line; "? " before it: fails only sometimes; text\n'
    '# after " #" is a comment. A test that needs what a page cannot have (a\n'
    '# socket, another program, the IDE) skips there, through the test\n'
    '# library\'s requirements (tests/_testlib.livecodescript), and is not here.\n')


def development_engine(bin_dir):
    """The development engine of a desktop build output folder."""
    for path in (os.path.join(bin_dir, 'LiveCode-Community'),
                 os.path.join(bin_dir, 'LiveCode-Community.exe'),
                 os.path.join(bin_dir, 'LiveCode-Community.app', 'Contents', 'MacOS', 'LiveCode-Community')):
        if os.path.isfile(path):
            return path
    raise CheckError('%s has no development engine (LiveCode-Community); pass --engine' % bin_dir)


def tests_text(root):
    """The text of every test file under root, for the names in it."""
    for folder, dirs, files in os.walk(root):
        dirs[:] = sorted(d for d in dirs if not d.startswith('.'))
        for name in sorted(files):
            if name.endswith('.livecodescript'):
                with open(os.path.join(folder, name), encoding='utf-8-sig', errors='replace') as f:
                    yield f.read()


def tree_files(folder, prefix):
    """(path in standalone.zip, file) of every file under folder, but those
    whose names, or the names of whose folders, start with "."."""
    found = []
    for root, dirs, files in os.walk(folder):
        dirs[:] = sorted(d for d in dirs if not d.startswith('.'))
        for name in sorted(files):
            if not name.startswith('.'):
                path = os.path.join(root, name)
                found.append((prefix + os.path.relpath(path, folder).replace(os.sep, '/'), path))
    return found


def standalone_files(repo, bin_dir, tests_list):
    """The files that the standalone gets besides its stack: see the
    header. tests_list is the text of web-tests.txt."""
    files = tree_files(os.path.join(repo, 'tests'), 'boot/standalone/tests/')
    build = os.path.join(repo, '_tests', '_build')
    files += tree_files(build, 'boot/standalone/_tests/_build/')
    texts = list(tests_text(os.path.join(repo, 'tests', 'lcs')))
    repo_files = set(ERROR_FILES)
    for text in texts:
        for path in re.findall(r'TestGetEngineRepositoryPath\(\)\s*&\s*"/([^"]+)"', text):
            if os.path.isfile(os.path.join(repo, path)):
                repo_files.add(path)
    for path in sorted(repo_files):
        files.append(('boot/standalone/' + path, os.path.join(repo, path)))
    # what tests read from the IDE's folder (TestGetIDERepositoryPath() &
    # "/<path>"), the plugins whose scripts they test: a folder whole
    for path in sorted(set(p for text in texts
                           for p in re.findall(r'TestGetIDERepositoryPath\(\)\s*&\s*"/([^"]+)"', text))):
        source = os.path.join(repo, 'ide', path)
        if os.path.isdir(source):
            files += tree_files(source, 'boot/standalone/ide/%s/' % path)
            repo_files.add('ide/%s/' % path)
        elif os.path.isfile(source):
            files.append(('boot/standalone/ide/' + path, source))
            repo_files.add('ide/' + path)
    # once each: a file in a folder that is also there whole
    files = list(dict(files).items())
    extensions = set()
    for text in texts:
        extensions.update(re.findall(r'TestLoadExtension\s+"([^"]+)"', text))
    for name in sorted(extensions):
        folder = os.path.join(bin_dir, 'packaged_extensions', name)
        if not os.path.isfile(os.path.join(folder, 'module.lcm')):
            raise CheckError('a test loads the extension %s, which %s does not have' % (
                name, os.path.join(bin_dir, 'packaged_extensions')))
        files.append(('boot/packaged_extensions/%s/module.lcm' % name, os.path.join(folder, 'module.lcm')))
        resources = os.path.join(folder, 'resources')
        if os.path.isdir(resources):
            files += tree_files(resources, 'boot/packaged_extensions/%s/resources/' % name)
    listing = os.path.join(os.path.dirname(build), 'web-tests.txt')
    with open(listing, 'w', encoding='utf-8', newline='\n') as f:
        f.write(tests_list)
    files.append(('boot/standalone/web-tests.txt', listing))
    return files, sorted(extensions), sorted(repo_files)


# ---------------------------------------------------------------------------
# The browser

class PageRun:
    """What one opening of the page did: the tests it began and ended, the
    TAP lines of each, and what the console said during each."""

    def __init__(self):
        self.count = None
        self.current = None     # the line of the test that has begun and not ended
        self.began = None       # when it began (time.time())
        self.tap = {}           # line: [TAP line]
        self.console = {}       # line: [console line]
        self.quit = set()       # the lines of tests that quit
        self.done = set()
        self.ended = False
        self.crash = None       # what stopped the engine
        self.last = time.time()  # when the page last said something
        self.on_done = None     # called with the line of each test that ends


def result_of(run, line, timeout):
    """(outcome, counts, TAP text, details, failure lines) of the test on
    line in the run."""
    text = '\n'.join(run.tap.get(line, []))
    counts, failures = analyse_tap(text)
    details = list(run.console.get(line, []))
    if line in run.done:
        outcome = outcome_of(counts, text)
    else:
        outcome = 'fail'
        details.insert(0, 'the engine stopped: %s' % run.crash if run.crash
                       else 'did not end within %d seconds' % timeout)
    if line in run.quit:
        outcome = 'fail'
        details.insert(0, 'the test quit (the runner cancelled the quit)')
    return outcome, counts, text, details, failures


def open_page(browser, url, start, run, timeout, stop_after=None):
    """Open the page at the test on line start, and follow it until the run
    ends, a test does not end within timeout seconds, or the engine stops;
    stop_after: the line after whose test to close the page."""
    from playwright.sync_api import Error as PlaywrightError
    context = browser.new_context(viewport={'width': 800, 'height': 600})
    page = context.new_page()

    def on_console(msg):
        text = msg.text
        run.last = time.time()
        if text.startswith('WEBTESTS '):
            words = text.split(' ', 3)
            kind = words[1]
            if kind == 'COUNT':
                run.count = int(words[2])
            elif kind == 'BEGIN':
                run.current = int(words[2])
                run.began = time.time()
                run.tap.setdefault(run.current, [])
            elif kind == 'TAP' and len(words) >= 3:
                run.tap.setdefault(int(words[2]), []).append(words[3] if len(words) > 3 else '')
            elif kind == 'QUIT':
                run.quit.add(int(words[2]) if len(words) > 2 and words[2].isdigit() else run.current)
            elif kind == 'DONE':
                run.done.add(int(words[2]))
                run.current = None
                if run.on_done:
                    run.on_done(int(words[2]))
            elif kind == 'END':
                run.ended = True
            return
        if run.current is not None:
            run.console.setdefault(run.current, []).append('console.%s: %s' % (msg.type, text))

    def on_page_error(error):
        text = str(error)
        if run.current is not None:
            run.console.setdefault(run.current, []).append('page error: %s' % text)
        # the engine's own abort (a trap of WebAssembly, or abort()) ends it
        if 'RuntimeError' in text or 'Aborted(' in text or 'unreachable' in text:
            run.crash = text

    def on_dialog(dialog):
        if run.current is not None:
            run.console.setdefault(run.current, []).append('browser dialog (%s): %s' % (dialog.type, dialog.message))
        try:
            dialog.accept()
        except PlaywrightError:
            pass

    page.on('console', on_console)
    page.on('pageerror', on_page_error)
    page.on('dialog', on_dialog)
    try:
        page.goto('%s?start=%d' % (url, start))
        while True:
            now = time.time()
            if run.ended or run.crash:
                break
            if stop_after is not None and stop_after in run.done:
                break
            if run.current is not None and now - run.began > timeout:
                break
            if run.current is None and now - run.last > timeout:
                # nothing began: the engine did not start, or stopped
                # between two tests
                if run.count is None:
                    raise CheckError('the page did not start the engine within %d seconds' % timeout)
                break
            # the page's dialogs (answer and ask): the default button
            try:
                dialog = page.locator('.oxt-dialog')
                if dialog.count() and dialog.first.is_visible():
                    if run.current is not None:
                        run.console.setdefault(run.current, []).append(
                            'page dialog: %r' % (dialog.first.text_content() or '')[:200])
                    dialog.first.locator('.oxt-dialog-default').click(timeout=2000)
            except PlaywrightError:
                pass
            page.wait_for_timeout(50)
    finally:
        try:
            context.close()
        except PlaywrightError:
            pass


def run_tests(url, tests, timeout, only=None, report=None):
    """Run the tests (lines 1 to len(tests) of web-tests.txt), or only the
    one on line only, in a page of its own. Returns {line: (outcome,
    counts, TAP text, details, failure lines)}; report is called with the
    line and the result of each test as it ends."""
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        raise CheckError('the Python package playwright is missing (pip install playwright, then '
                         'python3 -m playwright install chromium)')
    results = {}
    start = only or 1
    last = only or len(tests)

    def finish(line, result):
        if start <= line <= last and line not in results:
            results[line] = result
            if report:
                report(line, result)

    with sync_playwright() as p:
        browser = p.chromium.launch()
        try:
            while start <= last:
                run = PageRun()
                run.on_done = lambda line: finish(line, result_of(run, line, timeout))
                open_page(browser, url, start, run, timeout, stop_after=only)
                if run.count is not None and run.count != len(tests):
                    raise CheckError('the page has %d tests, expected %d' % (run.count, len(tests)))
                # the test that did not end
                for line in sorted(run.tap):
                    finish(line, result_of(run, line, timeout))
                # go on after the last test that began
                began = [x for x in run.tap if start <= x <= last]
                if run.ended or not began:
                    if not began:
                        finish(start, ('fail', {}, '', ['the engine stopped before the test began%s' % (
                            ': %s' % run.crash if run.crash else '')], []))
                    if run.ended or only:
                        break
                    start += 1
                    continue
                start = max(began) + 1
        finally:
            browser.close()
    return results


# ---------------------------------------------------------------------------

def write_baseline(path, failing, previous):
    """Rewrite the baseline: the failures, and the entries marked "?" (may
    pass) that it had, with their comments."""
    lines = BASELINE_HEADER.splitlines() + ['']
    keep = set(failing) | set(k for k, v in previous.items() if v[0])
    for ident in sorted(keep):
        sometimes, comment = previous.get(ident, (False, None))
        lines.append(('? ' if sometimes else '') + ident + ('  # ' + comment if comment else ''))
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(lines) + '\n')


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    ap.add_argument('--runtime', required=True, help='the web runtime folder')
    ap.add_argument('--bin', dest='bin_dir', required=True, metavar='DIR',
                    help='the build output of a desktop build of the checkout')
    ap.add_argument('--engine', help='the development engine to deploy with (default: --bin\'s)')
    ap.add_argument('--repo', default=REPO, metavar='DIR', help='source checkout (default: %(default)s)')
    ap.add_argument('--filter', metavar='REGEX', help='run only the tests whose "lcs: <test>" matches')
    ap.add_argument('--work', help='the work folder (default: a temporary folder)')
    ap.add_argument('--timeout', type=int, default=120, metavar='SECONDS',
                    help='time limit of one test, and of the engine starting (default: %(default)s)')
    ap.add_argument('--retries', type=int, default=1, metavar='N',
                    help='run a failed test that is not in the baseline again, on its own, at most N times '
                         '(default: %(default)s; 0 never)')
    ap.add_argument('--baseline', default=BASELINE, metavar='FILE', help='default: %(default)s')
    ap.add_argument('--update-baseline', action='store_true', help='rewrite the baseline with the failures')
    ap.add_argument('--log', metavar='FILE', help='default: <work>/web-tests.log')
    ap.add_argument('--log-all', action='store_true', help='log the output of every test, not only the failed')
    args = ap.parse_args(argv)

    repo = os.path.abspath(args.repo)
    bin_dir = os.path.abspath(args.bin_dir)
    work = os.path.abspath(args.work) if args.work else tempfile.mkdtemp(prefix='oxt-web-tests-')
    os.makedirs(work, exist_ok=True)
    log_path = os.path.abspath(args.log or os.path.join(work, 'web-tests.log'))
    known = run_engine_tests.read_baseline(args.baseline)
    started = time.monotonic()
    server = None
    log_lines = []
    try:
        runtime = os.path.abspath(args.runtime)
        version, js, wasm, html = web_check.runtime_files(runtime)
        engine = os.path.abspath(args.engine) if args.engine else development_engine(bin_dir)
        tools = {'lc-compile': os.path.join(bin_dir, 'lc-compile' + ('.exe' if os.name == 'nt' else '')),
                 'modules': os.path.join(bin_dir, 'modules', 'lci')}
        for path in tools.values():
            if not os.path.exists(path):
                raise CheckError('not in the build output: %s' % path)
        log('Web engine : %s' % js)
        log('Deploy with: %s' % engine)
        log('Checkout   : %s' % repo)

        tests = run_engine_tests.lcs_tests(os.path.join(repo, 'tests', 'lcs'), args.filter)
        if not tests:
            raise CheckError('no test matches')
        failed = run_engine_tests.compile_test_modules(tools, repo, log_lines)
        log('Compiled the test modules to %s%s' % (
            os.path.join(repo, '_tests', '_build'),
            '' if not failed else '; %d did not compile: %s' % (len(failed), ', '.join(failed))))
        tests_dir = os.path.join(repo, 'tests')
        listing = ''.join('/boot/standalone/tests/%s\t%s\n' % (
            os.path.relpath(path, tests_dir).replace(os.sep, '/'), name) for path, name, _ in tests)

        startup = web_check.deploy(engine, runtime, version, work, args.timeout, kind='tests',
                                   script=RUNNER_SCRIPT)
        site = os.path.join(work, 'site')
        shutil.rmtree(site, ignore_errors=True)
        files, extensions, repo_files = standalone_files(repo, bin_dir, listing)
        web_check.make_standalone(runtime, js, wasm, html, startup, site, files=files, title=TITLE)
        log('Standalone : %s (standalone.zip %.1f MB: %d files; the extensions %s; from the checkout %s)' % (
            site, os.path.getsize(os.path.join(site, 'standalone.zip')) / 1e6, len(files),
            ', '.join(extensions) or 'none', ', '.join(repo_files)))
        server = web_check.make_server(site)
        url = 'http://127.0.0.1:%d/%s.html' % (server.server_address[1], web_check.STACK_NAME)
        log('LiveCode Script tests: %d, in %s' % (len(tests), url))

        def report(line, result):
            ident = 'lcs: ' + tests[line - 1][2]
            log('%-5s %s%s' % (result[0].upper(), tests[line - 1][2],
                               ' (in the baseline)' if result[0] == 'fail' and ident in known else ''))

        raw = run_tests(url, tests, args.timeout, report=report)
        results = []
        for line, (path, name, ident) in enumerate(tests, 1):
            outcome, counts, text, details, failures = raw.get(
                line, ('fail', {}, '', ['the test did not run'], []))
            result = Result('lcs', ident, outcome, counts, text, details)
            result.failures = failures
            result.flaky = False
            results.append(result)
            if outcome == 'fail' and result.ident not in known:
                for attempt in range(args.retries):
                    again = run_tests(url, tests, args.timeout, only=line).get(line)
                    log('%-5s %s (on its own)' % (again[0].upper() if again else 'FAIL', ident))
                    if again and again[0] != 'fail':
                        result.flaky = True
                        result.outcome = again[0]
                        result.details = ['failed in the run, passed on its own (attempt %d)' % (attempt + 1)] \
                            + details
                        break
    except CheckError as e:
        log('error: %s' % e)
        run_engine_tests.append_summary('### Web engine tests\n\nThe tests could not be run: %s\n' % e)
        return 2
    finally:
        if server:
            server.shutdown()

    failing = [r for r in results if r.outcome == 'fail']
    flaky = [r for r in results if r.flaky]
    passed = set(r.ident for r in results if r.outcome in ('pass', 'xpass', 'xfail'))
    new = [r for r in failing if r.ident not in known]
    fixed = sorted(k for k, sometimes in known.items() if k in passed and not sometimes)
    totals = dict((k, sum(1 for r in results if r.outcome == k)) for k in RESULT_ORDER)
    elapsed = time.monotonic() - started

    with open(log_path, 'w', encoding='utf-8', newline='\n') as f:
        f.write('Web engine: %s\nCheckout: %s\nBaseline: %s\n\n' % (js, repo, os.path.abspath(args.baseline)))
        for line in log_lines:
            f.write(line + '\n')
        for r in results:
            if r.outcome in ('fail', 'xpass') or r.flaky or args.log_all:
                f.write('\n### %s %s%s\n' % ('FLAKY' if r.flaky else r.outcome.upper(), r.ident,
                                              '' if r.ident not in known else ' (in the baseline)'))
                for line in r.details:
                    f.write(line + '\n')
                if r.output:
                    f.write(r.output.rstrip() + '\n')
        f.write('\n%s\n' % ', '.join('%d %s' % (totals[k], k) for k in RESULT_ORDER))

    log('')
    log('%d tests in %.0f s: %s' % (len(results), elapsed, ', '.join('%d %s' % (totals[k], k)
                                                                      for k in RESULT_ORDER)))
    log('Failures: %d in the baseline, %d new' % (len(failing) - len(new), len(new)))
    for r in new:
        log('  NEW   %s' % r.ident)
        for line in r.failures[:10] + r.details[:20]:
            log('        %s' % line)
    if flaky:
        log('Flaky (failed in the run, then passed on their own; not counted as failures):')
        for r in flaky:
            log('  FLAKY %s' % r.ident)
    if fixed:
        log('Baseline entries that passed (remove them from the baseline):')
        for ident in fixed:
            log('  FIXED %s' % ident)
    log('Log: %s' % log_path)

    if args.update_baseline:
        write_baseline(args.baseline, [r.ident for r in failing],
                       run_engine_tests.baseline_entries(args.baseline))
        log('Wrote %s' % args.baseline)

    md = ['### Web engine tests', '',
          '%d LiveCode Script tests in the web engine in %.0f s: %s.' % (
              len(results), elapsed, ', '.join('%d %s' % (totals[k], k) for k in RESULT_ORDER)),
          '%d failure(s) in the baseline, **%d new**.' % (len(failing) - len(new), len(new))]
    if new:
        md += ['', 'New failures:', '', '```text']
        for r in new:
            md.append(r.ident)
            md += ['    ' + x for x in (r.failures[:5] + r.details[:8])]
        md.append('```')
    if flaky:
        md += ['', 'Flaky (failed in the run, then passed on their own):', '', '```text']
        md += [r.ident for r in flaky]
        md.append('```')
    if fixed:
        md += ['', 'Baseline entries that passed (remove them from the baseline):', '', '```text'] + fixed + ['```']
    run_engine_tests.append_summary('\n'.join(md))
    return 1 if new and not args.update_baseline else 0


if __name__ == '__main__':
    sys.exit(main())
