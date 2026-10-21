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

"""Build the remastered examples with an installed OXT-Beyond, check how
their windows route the arrow keys, and compare them with the committed
stacks.

  python3 tools/ci/examples_check.py --install DIR --out DIR
      [--log FILE] [--compare fail|report] [--print-stacks] [--timeout SECONDS]

1. The install's engine (its launcher, oxt-beyond, with -ui) runs
   tools/examples/build-examples.livecodescript, which builds every example
   from its builder in tools/examples into --out.
2. The install's Linux standalone engine opens the stacks built on an X
   server (xvfb-run when there is no DISPLAY) with
   tools/ci/examples-check.livecodescript: on every card, an arrow key sent
   to the window's frame reaches the card first, as one sent to the card
   does, and the cards whose programs play the arrow keys keep them. Then,
   as a report that fails nothing, it opens every card with its messages
   and lists the script errors.
3. Each stack built is compared with the one committed in
   ide/Resources/Examples/Remastered: a builder or the frame's script
   changed without its stack being built again shows as a difference.
   --compare fail makes a difference a failure (report, the default, only
   lists it), and --print-stacks prints each stack that differs into the
   log, for a machine without an engine to take the build from: as a delta
   from the committed stack, which is most of it, in lines
   "DELTA <file> <n>/<count> <base64>", or whole in lines
   "STACK <file> <n>/<count> <base64>" when there is none; then
   "SHA256 <file> <hex> <bytes>". Spaces in <file> are underscores.

  python3 tools/ci/examples_check.py --from-log FILE

takes those lines from a saved log and writes the stacks they make into
ide/Resources/Examples/Remastered, each checked against its SHA256 line.

Exit status 0 when the build and the checks passed (and, with --compare
fail, no stack differs), 1 otherwise. Under GitHub Actions a failure is an
annotation and the failures go into the job summary.
"""

import argparse
import base64
import hashlib
import os
import shutil
import struct
import subprocess
import sys
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
BUILD = os.path.join(REPO, 'tools', 'examples', 'build-examples.livecodescript')
SCRIPT = os.path.join(HERE, 'examples-check.livecodescript')
COMMITTED = os.path.join(REPO, 'ide', 'Resources', 'Examples', 'Remastered')
# a line of base64 in the log, as tools/ci/print_images.py writes images
CHUNK = 4000
# The delta's matching: the old stack's bytes are indexed every STRIDE
# bytes, BLOCK at a time, so any run the two share of BLOCK + STRIDE bytes
# or more is found
BLOCK = 24
STRIDE = 8


def log(msg=''):
    print(msg, flush=True)


def summary(text):
    path = os.environ.get('GITHUB_STEP_SUMMARY')
    if path:
        with open(path, 'a', encoding='utf-8', newline='\n') as f:
            f.write(text)


def run(cmd, env, timeout):
    try:
        proc = subprocess.run(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
        return proc.returncode, proc.stdout.decode('utf-8', 'replace').splitlines()
    except subprocess.TimeoutExpired as e:
        return None, (e.stdout or b'').decode('utf-8', 'replace').splitlines()


def build(install, out, timeout):
    """Builds the examples into out; returns a problem, or None"""
    if os.path.isdir(out):
        shutil.rmtree(out)
    os.makedirs(out)
    env = dict(os.environ, OXT_EXAMPLES_OUT=out, OXT_INSTALL=install)
    code, lines = run([os.path.join(install, 'oxt-beyond'), '-ui', BUILD], env, timeout)
    for line in lines:
        log('  ' + line)
    if code is None:
        return 'the build did not finish within %d seconds' % timeout
    if code != 0 or not lines or lines[-1].strip() != 'DONE':
        failed = [x for x in lines if x.startswith('FAILED')]
        return failed[0] if failed else 'the build stopped (exit status %s)' % code
    return None


def check(install, out, work, timeout, mode=''):
    """Runs the key check on the stacks in out (or, with mode 'cards', opens
    each card); returns its lines and problems"""
    engine = os.path.join(install, 'Runtime', 'Linux', 'x86-64', 'Standalone')
    if not os.path.isfile(engine):
        return [], ['no standalone engine at %s' % engine]
    result_log = os.path.join(work, 'examples-check-result%s.log' % ('-' + mode if mode else ''))
    if os.path.exists(result_log):
        os.remove(result_log)
    env = dict(os.environ, OXT_EXAMPLES_DIR=out, OXT_EXAMPLES_LOG=result_log, OXT_EXAMPLES_MODE=mode)
    cmd = [engine, SCRIPT]
    if not env.get('DISPLAY'):
        xvfb = shutil.which('xvfb-run')
        if not xvfb:
            return [], ['no DISPLAY and no xvfb-run']
        cmd = [xvfb, '-a', '-s', '-screen 0 1280x1024x24'] + cmd
    code, output = run(cmd, env, timeout)
    lines = []
    if os.path.exists(result_log):
        with open(result_log, encoding='utf-8', errors='replace') as f:
            lines = [x.rstrip('\r\n') for x in f if x.strip()]
    problems = [x[5:] for x in lines if x.startswith('FAIL ')]
    problems += [x for x in lines if x.startswith('ERROR ')]
    if 'QUIT' not in lines:
        problems.append('the engine did not finish (%s)' % ('timed out after %d seconds' % timeout
                                                          if code is None else 'exit status %s' % code))
        lines += ['engine: ' + x for x in output[-40:]]
    return lines, problems


def delta(old, new):
    """new as copies from old and bytes of its own, zlib-compressed: ops
    b'C' <offset> <length> and b'L' <length> <bytes>, lengths and offsets
    unsigned 32-bit big-endian"""
    index = {}
    for i in range(0, len(old) - BLOCK + 1, STRIDE):
        index.setdefault(old[i:i + BLOCK], i)
    ops = []
    lit = bytearray()
    j = 0
    expect = -1
    while j < len(new):
        i = -1
        if 0 <= expect and old[expect:expect + BLOCK] == new[j:j + BLOCK] and j + BLOCK <= len(new):
            i = expect
        elif j + BLOCK <= len(new):
            i = index.get(bytes(new[j:j + BLOCK]), -1)
        if i < 0:
            lit.append(new[j])
            j += 1
            continue
        # back into the bytes of its own, then on as far as the two agree
        back = 0
        while back < len(lit) and i - back > 0 and old[i - back - 1] == lit[len(lit) - back - 1]:
            back += 1
        if back:
            del lit[len(lit) - back:]
        i -= back
        start = j - back
        end = j + BLOCK
        while end < len(new) and i + (end - start) < len(old) and old[i + end - start] == new[end]:
            end += 1
        if lit:
            ops.append(b'L' + struct.pack('>I', len(lit)) + bytes(lit))
            lit = bytearray()
        ops.append(b'C' + struct.pack('>II', i, end - start))
        j = end
        expect = i + (end - start)
    if lit:
        ops.append(b'L' + struct.pack('>I', len(lit)) + bytes(lit))
    return zlib.compress(b''.join(ops), 9)


def undelta(old, data):
    """The bytes a delta makes from old"""
    ops = zlib.decompress(data)
    out = bytearray()
    k = 0
    while k < len(ops):
        if ops[k:k + 1] == b'C':
            off, length = struct.unpack('>II', ops[k + 1:k + 9])
            if off + length > len(old):
                raise ValueError('a copy past the end of the old stack')
            out += old[off:off + length]
            k += 9
        elif ops[k:k + 1] == b'L':
            (length,) = struct.unpack('>I', ops[k + 1:k + 5])
            out += ops[k + 5:k + 5 + length]
            k += 5 + length
        else:
            raise ValueError('not a delta')
    return bytes(out)


def print_lines(kind, name, data):
    text = base64.b64encode(data).decode('ascii')
    parts = [text[i:i + CHUNK] for i in range(0, len(text), CHUNK)] or ['']
    for i, part in enumerate(parts, 1):
        print('%s %s %d/%d %s' % (kind, name.replace(' ', '_'), i, len(parts), part))


def from_log(path, committed=COMMITTED):
    """Writes the stacks of a log's DELTA or STACK and SHA256 lines into
    committed; returns the problems"""
    parts = {}
    sums = {}
    with open(path, encoding='utf-8', errors='replace') as f:
        for line in f:
            # (a GitHub log puts a time before each line)
            words = line.split()
            for k, w in enumerate(words):
                if w in ('DELTA', 'STACK') and len(words) >= k + 4 and '/' in words[k + 2]:
                    n, count = words[k + 2].split('/')
                    parts.setdefault((w, words[k + 1]), {})[int(n)] = (int(count), words[k + 3])
                    break
                if w == 'SHA256' and len(words) >= k + 4:
                    sums[words[k + 1]] = (words[k + 2], int(words[k + 3]))
                    break
    problems = []
    names = {}
    for (kind, name), got in parts.items():
        count = next(iter(got.values()))[0]
        if sorted(got) != list(range(1, count + 1)):
            problems.append('%s: %d of its %d lines' % (name, len(got), count))
            continue
        names[name] = (kind, base64.b64decode(''.join(got[i][1] for i in range(1, count + 1))))
    for name, (kind, data) in sorted(names.items()):
        # (the file the underscores were spaces of)
        target = None
        for x in os.listdir(committed):
            if x.replace(' ', '_') == name:
                target = os.path.join(committed, x)
        if target is None:
            target = os.path.join(committed, name.replace('_', ' '))
        if kind == 'DELTA':
            with open(target, 'rb') as f:
                data = undelta(f.read(), data)
        if name not in sums:
            problems.append('%s: no SHA256 line' % name)
            continue
        if hashlib.sha256(data).hexdigest() != sums[name][0] or len(data) != sums[name][1]:
            problems.append('%s: not the stack the log names (its SHA256 or size differs)' % name)
            continue
        with open(target, 'wb') as f:
            f.write(data)
        log('%s: written (%d bytes)' % (os.path.basename(target), len(data)))
    return problems


def compare(out, print_stacks):
    """The stacks built that are not the committed ones, by file name"""
    built = sorted(x for x in os.listdir(out) if x.endswith('.oxtstack'))
    committed = sorted(x for x in os.listdir(COMMITTED) if x.endswith('.oxtstack'))
    differ = []
    for name in sorted(set(built) | set(committed)):
        if name not in built:
            log('  %s: committed, not built' % name)
            differ.append(name)
            continue
        with open(os.path.join(out, name), 'rb') as f:
            data = f.read()
        old = None
        if name in committed:
            with open(os.path.join(COMMITTED, name), 'rb') as f:
                old = f.read()
        if data == old:
            log('  %s: the same (%d bytes)' % (name, len(data)))
            continue
        log('  %s: %s (%d bytes built, %s committed)' % (name, 'differs' if old is not None else 'new',
                                                        len(data), len(old) if old is not None else 'none'))
        differ.append(name)
        if print_stacks:
            if old is not None:
                print_lines('DELTA', name, delta(old, data))
            else:
                print_lines('STACK', name, data)
            print('SHA256 %s %s %d' % (name.replace(' ', '_'), hashlib.sha256(data).hexdigest(), len(data)))
            sys.stdout.flush()
    return differ


def main(argv=None):
    ap = argparse.ArgumentParser(description='Build and check the remastered examples.')
    ap.add_argument('--from-log', metavar='FILE',
                    help='write the stacks a log of --print-stacks holds into the committed folder, and stop')
    ap.add_argument('--install', metavar='DIR', help='an installed (extracted) OXT-Beyond')
    ap.add_argument('--out', metavar='DIR', help='where the examples are built (emptied first)')
    ap.add_argument('--log', metavar='FILE', help='write the check\'s lines here')
    ap.add_argument('--compare', choices=('fail', 'report'), default='report',
                    help='whether a stack that differs from the committed one fails the check (default: %(default)s)')
    ap.add_argument('--print-stacks', action='store_true', help='print each stack that differs, base64, into the log')
    ap.add_argument('--timeout', type=int, default=600, help='seconds for each step (default: %(default)s)')
    args = ap.parse_args(argv)
    if args.from_log:
        problems = from_log(args.from_log)
        for p in problems:
            log('  ' + p)
        return 1 if problems else 0
    if not args.install or not args.out:
        ap.error('--install and --out are needed')

    install = os.path.abspath(args.install)
    out = os.path.abspath(args.out)
    work = os.path.dirname(out)
    problems = []
    log('Install : %s' % install)
    log('Out     : %s' % out)
    log('')

    log('Building the examples:')
    problem = build(install, out, args.timeout)
    if problem:
        problems.append('build: ' + problem)
    else:
        log('')
        log('Checking the arrow keys:')
        lines, found = check(install, out, work, args.timeout)
        for line in lines:
            if not line.startswith('PASS '):
                log('  ' + line)
        log('  (%d checks passed)' % sum(1 for x in lines if x.startswith('PASS ')))
        if args.log:
            with open(args.log, 'w', encoding='utf-8', newline='\n') as f:
                f.write('\n'.join(lines) + '\n')
        problems += found
        log('')
        # (reported, not a failure: a standalone engine has none of the
        # IDE's libraries, such as the data grid's, that some cards use)
        log('Opening every card (a report):')
        lines, found = check(install, out, work, min(args.timeout, 180), 'cards')
        for line in lines:
            log('  ' + line)
        log('  (%d script error(s); %d other problem(s))' % (sum(1 for x in lines if x.startswith('SCRIPTERROR ')),
                                                           len([x for x in found if not x.startswith('SCRIPTERROR')])))
        log('')
        log('Comparing with the committed stacks:')
        differ = compare(out, args.print_stacks)
        if differ:
            note = ('%d stack(s) differ from their build: %s. Build them again '
                    '(tools/examples/README.md) and commit them.' % (len(differ), ', '.join(differ)))
            log('  ' + note)
            if args.compare == 'fail':
                problems.append(note)
            elif os.environ.get('GITHUB_ACTIONS') == 'true':
                log('::warning title=Remastered examples::%s' % note)

    log('')
    if not problems:
        log('Examples check: passed.')
        return 0
    log('Examples check: FAILED: %d problem(s)' % len(problems))
    for p in problems:
        log('  ' + p)
    if os.environ.get('GITHUB_ACTIONS') == 'true':
        log('::error title=Examples check::%s' % problems[0])
        summary('### Examples check failed\n\n' + ''.join('- `%s`\n' % x for x in problems[:50]) + '\n')
    return 1


if __name__ == '__main__':
    sys.exit(main())
