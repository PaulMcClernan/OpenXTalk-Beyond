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

"""Check the courses of the xTalk Academy: run every lesson as a learner
would, with the Academy's own runner.

  python3 tools/ci/academy_check.py (--engine FILE | --bin DIR)
      [--toolset DIR] [--log FILE] [--timeout SECONDS]

The engine (--engine, or the development engine of a build output, --bin)
runs tools/ci/academy-check.livecodescript without the IDE (-ui). That
script loads the Academy (Toolset/palettes/academy/revacademy.livecodescript)
and revLearnKit from --toolset (default: this checkout's ide/Toolset), and
for every course file checks that each example runs (or stops with an
error, when it says it does), that each quick check has one right answer,
and that each challenge's solution passes its checks while its starter
code does not.

Exit status 0 when everything passed, 1 otherwise. Under GitHub Actions a
failure is an annotation and the failures go into the job summary.
"""

import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRIPT = os.path.join(HERE, 'academy-check.livecodescript')
DEV = {'win32': 'LiveCode-Community.exe',
       'darwin': 'LiveCode-Community.app/Contents/MacOS/LiveCode-Community'}


def log(msg=''):
    print(msg, flush=True)


def summary(text):
    path = os.environ.get('GITHUB_STEP_SUMMARY')
    if path:
        with open(path, 'a', encoding='utf-8', newline='\n') as f:
            f.write(text)


def main(argv=None):
    ap = argparse.ArgumentParser(description='Check the courses of the xTalk Academy.')
    given = ap.add_mutually_exclusive_group(required=True)
    given.add_argument('--engine', metavar='FILE', help='the engine to run')
    given.add_argument('--bin', dest='bin_dir', metavar='DIR', help='a build output, whose development engine runs')
    ap.add_argument('--toolset', metavar='DIR', default=os.path.join(REPO, 'ide', 'Toolset'),
                    help='the Toolset whose Academy is checked (default: %(default)s)')
    ap.add_argument('--log', metavar='FILE', help='write the engine\'s output here')
    ap.add_argument('--timeout', type=int, default=600, help='seconds (default: %(default)s)')
    args = ap.parse_args(argv)

    engine = args.engine or os.path.join(args.bin_dir, *DEV.get(sys.platform, 'LiveCode-Community').split('/'))
    toolset = os.path.abspath(args.toolset)
    if not os.path.isfile(engine):
        log('ERROR engine not found: %s' % engine)
        return 1
    if not os.path.isfile(os.path.join(toolset, 'palettes', 'academy', 'revacademy.livecodescript')):
        log('ERROR no Academy in %s' % toolset)
        return 1
    log('Engine  : %s' % engine)
    log('Toolset : %s' % toolset)
    log('')

    env = dict(os.environ, OXT_ACADEMY_TOOLSET=toolset)
    try:
        proc = subprocess.run([engine, '-ui', SCRIPT], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              timeout=args.timeout)
        code = proc.returncode
        out = proc.stdout.decode('utf-8', 'replace').splitlines()
        err = [x for x in proc.stderr.decode('utf-8', 'replace').splitlines() if x.strip()]
    except subprocess.TimeoutExpired as e:
        code = None
        out = (e.stdout or b'').decode('utf-8', 'replace').splitlines()
        err = (e.stderr or b'').decode('utf-8', 'replace').splitlines()

    if args.log:
        with open(args.log, 'w', encoding='utf-8', newline='\n') as f:
            f.write('\n'.join(out + err) + '\n')
    failures = [x for x in out if x.startswith(('FAIL ', 'ERROR '))]
    for line in out:
        if not line.startswith('PASS '):
            log(line)
    if err:
        log('')
        log('Engine stderr:')
        for line in err:
            log('  ' + line)
    done = any(x.startswith('SUMMARY ') for x in out)

    gha = os.environ.get('GITHUB_ACTIONS') == 'true'
    if code == 0 and done and not failures:
        log('')
        log('Academy check: passed.')
        return 0
    if code is None:
        problem = 'the engine did not finish within %d seconds' % args.timeout
    elif not done:
        problem = 'the engine stopped (exit status %s) before the end' % code
    else:
        problem = '%d failure(s)' % len(failures)
    log('')
    log('Academy check: FAILED: %s' % problem)
    if gha:
        log('::error title=Academy check::%s' % problem)
        summary('### Academy check failed\n\n%s\n\n' % problem +
                ''.join('- `%s`\n' % x for x in failures[:50]) + '\n')
    return 1


if __name__ == '__main__':
    sys.exit(main())
