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

"""Build a web standalone from the web runtime and run it in a headless
browser.

  python3 tools/ci/web_check.py --runtime DIR (--engine FILE | --engine-cache DIR)
      [--work DIR] [--timeout SECONDS] [--keep-serving]

--runtime is the web runtime: the folder that the IDE's web builder takes
its files from (Runtime/Emscripten/js in an installed OXT-Beyond, and the
web build's output in CI), which holds

  standalone-community-<version>.js and .wasm   the engine
  standalone-community-<version>.html           the page template
  emscripten-standalone-template/               the files every standalone
                                                gets (its font)
  emscripten-startup-template.livecodescript    the startup script template

--engine is a development engine (LiveCode-Community) to deploy the stack
with; --engine-cache downloads the Linux x86_64 engine of the OXT-Beyond
release that tools/ci/build_docs.sh pins into that folder instead (checked
against its SHA-256). Any engine can deploy for the web: the deploy command
only writes the stack and the startup script.

1. The standalone, as the IDE's builder makes it
   (ide-support/revsaveasemscriptenstandalone.livecodescript): the
   development engine runs tools/ci/web-deploy.livecodescript, which saves
   the probe stack (tools/ci/web-probe.livecodescript, with a button, a
   field, a graphic and a PNG image) and writes its startup data with
   "_internal deploy emscripten"; standalone.zip gets the template folder
   (without dotfiles) and boot/__startup.data, and the folder gets the
   engine's .js and .wasm and the page, WebProbe.html, with the stack's
   title in its <title>.

2. A web server on 127.0.0.1 serves the folder, and the requests the probe
   makes: GET /probe-data.txt, POST /echo (which answers "POST
   <Content-Type> <body>"), PUT and GET /store, and a 404.

3. Headless Chromium (Playwright) opens the page. The probe writes PROBE
   lines to the console (see web-probe.livecodescript): its checks of
   waits (in openStack, in handlers, nested, with messages, until a
   condition), "send ... in", "do ... as JavaScript", files, URLs (get,
   post, put, load with message, a missing page) and the browser dialogs
   (answer, answer with two buttons, ask), which this script accepts,
   giving "Ada" to the prompt. When the probe writes "PROBE ready", this
   script clicks the button, types "abc" into the field, and calls the
   stack's handlers from the page (document.liveCode.findStackWithName):
   probeFromJS(21) must return 42, and probeReport() "abc|abc|1". Then it
   takes a screenshot of the stack and checks the colours of the card, the
   graphic and the image in it.

Every check must pass, and nothing may reach the browser's error console
or the page's error handler. The screenshot is written to
<work>/WebProbe.png. --keep-serving keeps the server running after the
checks (Ctrl-C ends it), to open the page in a browser by hand.

Exit status 0 when everything passes, 1 otherwise. Under GitHub Actions
it writes annotations and a job summary. Needs Python 3.8 or later and,
for the browser, the Python package playwright with its Chromium
(python3 -m playwright install chromium).
"""

import argparse
import hashlib
import http.server
import os
import re
import shutil
import socketserver
import subprocess
import sys
import tarfile
import tempfile
import threading
import time
import urllib.request
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
DEPLOY_SCRIPT = os.path.join(HERE, 'web-deploy.livecodescript')
PROBE_SCRIPT = os.path.join(HERE, 'web-probe.livecodescript')
BUILD_DOCS = os.path.join(HERE, 'build_docs.sh')

STACK_NAME = 'WebProbe'
STACK_TITLE = 'Web Probe'
PROBE_DATA = 'probe data 123'
PROMPT_ANSWER = 'Ada'

# The checks the probe makes before it is ready, in its order
PROBE_CHECKS = (
    'platform', 'wait-openstack', 'wait-handler', 'wait-nested', 'wait-until', 'send-in-time',
    'javascript', 'file-roundtrip', 'standalone-folder', 'url-get', 'url-post', 'url-put',
    'url-missing', 'url-load', 'answer-confirm', 'ask', 'objects',
)

# Colours in the screenshot, at points of the card (the probe's stack is
# 480x360; see web-deploy.livecodescript)
COLOURS = (
    ('card', (440, 320), (0x33, 0x66, 0xCC)),
    ('graphic', (350, 90), (0xCC, 0x33, 0x00)),
    ('image', (312, 212), (0, 170, 0)),
)


def log(msg=''):
    print(msg, flush=True)


def gha():
    return os.environ.get('GITHUB_ACTIONS') == 'true'


def annotate(kind, msg):
    if gha():
        print('::%s::%s' % (kind, msg.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')), flush=True)


def summary(text):
    path = os.environ.get('GITHUB_STEP_SUMMARY')
    if path:
        with open(path, 'a', encoding='utf-8') as f:
            f.write(text)


class CheckError(Exception):
    pass


# ---------------------------------------------------------------------------
# The engines

def runtime_files(runtime):
    """(version, js, wasm, html) of the web runtime folder."""
    found = {}
    for name in os.listdir(runtime):
        m = re.match(r'^standalone-community-(.+)\.(js|wasm|html)$', name)
        if m:
            found.setdefault(m.group(1), {})[m.group(2)] = os.path.join(runtime, name)
    complete = [v for v, files in found.items() if len(files) == 3]
    if len(complete) != 1:
        raise CheckError('%s must hold one engine, standalone-community-<version>.js, .wasm and .html; it has %s'
                         % (runtime, ', '.join(sorted(os.listdir(runtime))) or 'nothing'))
    version = complete[0]
    files = found[version]
    for name in ('emscripten-standalone-template', 'emscripten-startup-template.livecodescript'):
        if not os.path.exists(os.path.join(runtime, name)):
            raise CheckError('%s has no %s' % (runtime, name))
    return version, files['js'], files['wasm'], files['html']


def pinned_engine():
    """(version, url, sha256) of the engine that build_docs.sh pins."""
    with open(BUILD_DOCS, encoding='utf-8') as f:
        text = f.read()
    values = dict(re.findall(r'(?m)^DOCS_ENGINE_(VERSION|URL|SHA256)=(\S+)$', text))
    if sorted(values) != ['SHA256', 'URL', 'VERSION']:
        raise CheckError('%s does not pin an engine (DOCS_ENGINE_VERSION, _URL, _SHA256)' % BUILD_DOCS)
    url = values['URL'].replace('$DOCS_ENGINE_VERSION', values['VERSION'])
    return values['VERSION'], url, values['SHA256']


def sha256_of(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for block in iter(lambda: f.read(1 << 20), b''):
            h.update(block)
    return h.hexdigest()


def fetch_engine(cache):
    """The development engine of the pinned release, downloaded into cache
    (once)."""
    version, url, sha256 = pinned_engine()
    os.makedirs(cache, exist_ok=True)
    folder = os.path.join(cache, 'engine-' + version)
    engine = os.path.join(folder, 'linux-x86_64-bin', 'LiveCode-Community')
    if os.path.isfile(engine):
        return engine
    tarball = os.path.join(cache, url.rsplit('/', 1)[1])
    if not os.path.isfile(tarball) or sha256_of(tarball) != sha256:
        log('Downloading the development engine of OXT-Beyond %s' % version)
        with urllib.request.urlopen(url, timeout=300) as r, open(tarball + '.part', 'wb') as f:
            shutil.copyfileobj(r, f)
        os.replace(tarball + '.part', tarball)
    if sha256_of(tarball) != sha256:
        raise CheckError('%s does not have the SHA-256 that build_docs.sh pins' % tarball)
    shutil.rmtree(folder, ignore_errors=True)
    with tarfile.open(tarball) as tar:
        tar.extractall(folder)
    if not os.path.isfile(engine):
        raise CheckError('%s has no linux-x86_64-bin/LiveCode-Community' % tarball)
    return engine


# ---------------------------------------------------------------------------
# 1. The standalone

def deploy(engine, runtime, version, work, timeout):
    """Write <work>/__startup.data with the development engine."""
    stack = os.path.join(work, STACK_NAME + '.livecode')
    output = os.path.join(work, '__startup.data')
    env = dict(os.environ)
    env.update(OXT_WEB_PROBE=PROBE_SCRIPT, OXT_WEB_STACK=stack, OXT_WEB_OUTPUT=output, OXT_WEB_VERSION=version,
               OXT_WEB_TEMPLATE=os.path.join(runtime, 'emscripten-startup-template.livecodescript'))
    try:
        r = subprocess.run([engine, '-ui', DEPLOY_SCRIPT], cwd=work, env=env, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE, timeout=timeout)
    except subprocess.TimeoutExpired:
        raise CheckError('the deploy did not finish within %d seconds' % timeout)
    except OSError as e:
        raise CheckError('cannot run %s: %s' % (engine, e))
    out = r.stdout.decode('utf-8', 'replace').splitlines()
    for line in out + r.stderr.decode('utf-8', 'replace').splitlines():
        if line.strip():
            log('  deploy: %s' % line)
    if r.returncode != 0 or not any(x.startswith('DEPLOY OK') for x in out):
        why = next((x for x in out if x.startswith('DEPLOY FAILED')), 'exit status %s, no DEPLOY line' % r.returncode)
        raise CheckError('deploying the probe stack failed: %s' % why)
    return output


def make_standalone(runtime, js, wasm, html, startup_data, site):
    """The standalone folder <site>, as the builder makes it."""
    os.makedirs(site, exist_ok=True)
    template = os.path.join(runtime, 'emscripten-standalone-template')
    with zipfile.ZipFile(os.path.join(site, 'standalone.zip'), 'w', zipfile.ZIP_STORED) as z:
        # the builder's scanFolder leaves out names that start with "."
        for root, dirs, files in os.walk(template):
            dirs[:] = sorted(d for d in dirs if not d.startswith('.'))
            for name in sorted(files):
                if not name.startswith('.'):
                    path = os.path.join(root, name)
                    z.write(path, os.path.relpath(path, template).replace(os.sep, '/'))
        z.write(startup_data, 'boot/__startup.data')
    for path in (js, wasm):
        shutil.copyfile(path, os.path.join(site, os.path.basename(path)))
    with open(html, encoding='utf-8') as f:
        page = f.read()
    if '@STACK_TITLE@' not in page:
        raise CheckError('%s has no @STACK_TITLE@ for the builder to replace' % html)
    page = page.replace('@STACK_TITLE@', STACK_TITLE)
    with open(os.path.join(site, STACK_NAME + '.html'), 'w', encoding='utf-8') as f:
        f.write(page)


# ---------------------------------------------------------------------------
# 2. The web server

def make_server(site):
    stored = {}

    class Handler(http.server.SimpleHTTPRequestHandler):
        extensions_map = dict(http.server.SimpleHTTPRequestHandler.extensions_map,
                              **{'.wasm': 'application/wasm', '.js': 'text/javascript'})

        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=site, **kwargs)

        def log_message(self, fmt, *args):
            pass

        def reply(self, code, body, content_type='text/plain; charset=utf-8'):
            data = body.encode('utf-8')
            self.send_response(code)
            self.send_header('Content-Type', content_type)
            self.send_header('Content-Length', str(len(data)))
            self.send_header('Cache-Control', 'no-store')
            self.end_headers()
            self.wfile.write(data)

        def body(self):
            return self.rfile.read(int(self.headers.get('Content-Length') or 0)).decode('utf-8', 'replace')

        def do_GET(self):
            if self.path == '/probe-data.txt':
                return self.reply(200, PROBE_DATA)
            if self.path == '/store':
                return self.reply(200, stored.get('store', ''))
            if self.path == '/missing':
                return self.reply(404, 'not found')
            return super().do_GET()

        def do_POST(self):
            if self.path == '/echo':
                return self.reply(200, 'POST %s %s' % (self.headers.get('Content-Type', ''), self.body()))
            return self.reply(404, 'not found')

        def do_PUT(self):
            if self.path == '/store':
                stored['store'] = self.body()
                return self.reply(201, '')
            return self.reply(404, 'not found')

    class Server(socketserver.ThreadingMixIn, http.server.HTTPServer):
        daemon_threads = True

    server = Server(('127.0.0.1', 0), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


# ---------------------------------------------------------------------------
# 3. The browser

def parse_rect(text):
    parts = [int(x) for x in text.split(',')]
    if len(parts) != 4:
        raise CheckError('not a rectangle: %r' % text)
    return parts


def run_browser(url, version, work, timeout):
    """Open the page and check what the probe and the page do. Returns
    (problems, lines)."""
    try:
        from playwright.sync_api import sync_playwright, Error as PlaywrightError
    except ImportError:
        raise CheckError('the Python package playwright is missing (pip install playwright, then '
                         'python3 -m playwright install chromium)')
    problems, lines, console, page_errors = [], [], [], []
    probes = {}
    info = {}

    def on_console(msg):
        text = msg.text
        console.append((msg.type, text))
        if text.startswith('PROBE '):
            log('  %s' % text)
            parts = text[6:].split(' ', 2) + ['', '']
            if parts[0] == 'info':
                info[parts[1]] = parts[2]
            else:
                probes.setdefault(parts[0], []).append((parts[1], parts[2]))
        else:
            log('  console.%s: %s' % (msg.type, text))

    def on_dialog(dialog):
        log('  dialog (%s): %s' % (dialog.type, dialog.message))
        if dialog.type == 'prompt':
            dialog.accept(PROMPT_ANSWER)
        else:
            dialog.accept()

    def on_page_error(error):
        page_errors.append(str(error))
        log('  page error: %s' % error)

    def wait_for(predicate, what, seconds):
        deadline = time.time() + seconds
        while time.time() < deadline:
            if predicate():
                return True
            if page_errors:
                return False
            page.wait_for_timeout(100)
        problems.append('%s did not happen within %d seconds' % (what, seconds))
        return False

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={'width': 800, 'height': 600})
        page.on('console', on_console)
        page.on('dialog', on_dialog)
        page.on('pageerror', on_page_error)
        started = time.time()
        page.goto(url)
        if not wait_for(lambda: 'version' in info, 'the engine starting (PROBE info version)', timeout):
            problems.append('the page did not start the engine')
        else:
            lines.append('the engine started in %.1f s' % (time.time() - started))
            if info['version'] != version:
                problems.append('the engine reports the version %r, expected %r' % (info['version'], version))
            if wait_for(lambda: 'ready' in probes, 'the probe\'s checks', timeout):
                lines.append('the probe ran its checks in %.1f s' % (time.time() - started))
            title = page.title()
            if title != STACK_TITLE:
                problems.append('the page\'s title is %r, expected %r' % (title, STACK_TITLE))
        if 'ready' in probes and not page_errors:
            try:
                canvas = page.locator('#canvas').bounding_box()
                if not canvas:
                    raise CheckError('the page has no canvas')

                def at(rect):
                    left, top, right, bottom = parse_rect(rect)
                    return canvas['x'] + (left + right) / 2, canvas['y'] + (top + bottom) / 2

                # a click on the button, and keys typed into the field
                page.mouse.click(*at(info['button-rect']))
                wait_for(lambda: 'click' in probes, 'the button\'s mouseUp', 10)
                page.mouse.click(*at(info['field-rect']))
                page.wait_for_timeout(200)
                page.keyboard.type('abc', delay=50)
                page.wait_for_timeout(300)
                # the stack's handlers, called from the page
                result = page.evaluate("document.liveCode.findStackWithName('%s').probeFromJS(21)" % STACK_NAME)
                if str(result) != '42':
                    problems.append('probeFromJS(21) returned %r from the page, expected 42' % (result,))
                report = page.evaluate("document.liveCode.findStackWithName('%s').probeReport()" % STACK_NAME)
                if report != 'abc|abc|1':
                    problems.append('probeReport() returned %r, expected the field\'s text, the keys and the '
                                    'clicks: \'abc|abc|1\'' % (report,))
                else:
                    lines.append('a click, typing and calls from the page reached the stack')
                # the colours drawn
                shot = os.path.join(work, STACK_NAME + '.png')
                page.screenshot(path=shot, clip=dict(x=canvas['x'], y=canvas['y'],
                                                     width=canvas['width'], height=canvas['height']))
                pixels = page.evaluate('''([x, y, points]) => {
                    const c = document.getElementById('canvas');
                    const ctx = c.getContext('2d');
                    return points.map(([px, py]) => Array.from(ctx.getImageData(px, py, 1, 1).data.slice(0, 3)));
                }''', [canvas['x'], canvas['y'], [list(pt) for _, pt, _ in COLOURS]])
                for (name, point, want), got in zip(COLOURS, pixels):
                    if any(abs(a - b) > 8 for a, b in zip(got, want)):
                        problems.append('the %s at %s is drawn %s, expected %s' % (name, point, tuple(got), want))
                lines.append('canvas %dx%d at (%d, %d); screenshot %s' % (
                    canvas['width'], canvas['height'], canvas['x'], canvas['y'], shot))
            except (CheckError, PlaywrightError, KeyError, ValueError) as e:
                problems.append('the interactive checks failed: %s' % e)
        browser.close()

    for name in PROBE_CHECKS:
        results = probes.get(name)
        if not results:
            problems.append('the probe did not report the check %s' % name)
        for status, detail in results or []:
            if status != 'PASS':
                problems.append('%s: %s %s' % (name, status, detail))
    for name, results in sorted(probes.items()):
        if name not in PROBE_CHECKS and name not in ('ready', 'click'):
            for status, detail in results:
                if status != 'PASS':
                    problems.append('%s: %s %s' % (name, status, detail))
    if not probes.get('click'):
        problems.append('the click on the button did not reach its mouseUp handler')
    if 'wait=refused' not in info.get('js-call', ''):
        problems.append('a wait in a handler called from the page did not fail as it must: %r'
                        % info.get('js-call'))
    for error in page_errors:
        problems.append('page error: %s' % error)
    # The browser reports the probe's request for a missing page (url-missing)
    expected = ['Failed to load resource: the server responded with a status of 404 (Not Found)']
    for kind, text in console:
        if kind == 'error' and not text.startswith('PROBE '):
            if text in expected:
                expected.remove(text)
            else:
                problems.append('console error: %s' % text)
    return problems, lines


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    ap.add_argument('--runtime', required=True, help='the web runtime folder')
    group = ap.add_mutually_exclusive_group(required=True)
    group.add_argument('--engine', help='a development engine (LiveCode-Community)')
    group.add_argument('--engine-cache', help='download the pinned development engine into this folder')
    ap.add_argument('--work', help='the work folder (default: a temporary folder)')
    ap.add_argument('--timeout', type=int, default=120, help='seconds for each step (default 120)')
    ap.add_argument('--keep-serving', action='store_true', help='keep serving the page after the checks')
    args = ap.parse_args(argv)

    work = os.path.abspath(args.work) if args.work else tempfile.mkdtemp(prefix='oxt-web-check-')
    os.makedirs(work, exist_ok=True)
    problems, lines = [], []
    server = None
    try:
        runtime = os.path.abspath(args.runtime)
        version, js, wasm, html = runtime_files(runtime)
        log('Web engine %s: %s (%.1f MB), %s (%.1f MB)' % (
            version, os.path.basename(js), os.path.getsize(js) / 1e6, os.path.basename(wasm),
            os.path.getsize(wasm) / 1e6))
        lines.append('web engine %s: .wasm %.1f MB, .js %.0f kB' % (
            version, os.path.getsize(wasm) / 1e6, os.path.getsize(js) / 1e3))
        engine = os.path.abspath(args.engine) if args.engine else fetch_engine(os.path.abspath(args.engine_cache))
        log('Deploying with %s' % engine)
        startup = deploy(engine, runtime, version, work, args.timeout)
        site = os.path.join(work, 'site')
        shutil.rmtree(site, ignore_errors=True)
        make_standalone(runtime, js, wasm, html, startup, site)
        lines.append('standalone.zip %.1f kB' % (os.path.getsize(os.path.join(site, 'standalone.zip')) / 1e3))
        server = make_server(site)
        url = 'http://127.0.0.1:%d/%s.html' % (server.server_address[1], STACK_NAME)
        log('Opening %s' % url)
        p, l = run_browser(url, version, work, args.timeout)
        problems += p
        lines += l
        if args.keep_serving:
            log('Serving %s (Ctrl-C ends it)' % url)
            try:
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                pass
    except CheckError as e:
        problems.append(str(e))
    finally:
        if server:
            server.shutdown()

    log()
    for line in lines:
        log('  ' + line)
    if problems:
        log('FAILED:')
        for problem in problems:
            log('  ' + problem)
            annotate('error', 'web check: ' + problem)
    else:
        log('PASSED')
    summary('### Web standalone check\n\n' + ''.join('- %s\n' % x for x in lines)
            + ('\n**Failed:**\n\n' + ''.join('- %s\n' % x for x in problems) if problems else '\nAll checks passed.\n')
            + '\n')
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main())
