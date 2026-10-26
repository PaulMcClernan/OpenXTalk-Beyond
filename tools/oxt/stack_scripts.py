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

"""The scripts inside the binary IDE stacks, as text files in stack-scripts/.

Git cannot show what changed inside a binary stack, so every object script
of every binary stack in ide/ and ide-support/ is also kept as a file of its
own, where a diff, a review and an editor's search can see it:

  stack-scripts/<stack file>.bst/scripts/<name>.livecodescript

laid out and named as Brian Milby's BST names its exports
(https://github.com/Milby-Computer/hxt-bst): stack_<stack> for a stack's own
script, stack_<stack>_<type>_id_<id> for an object's, with the innermost
stack for an object in a substack; any character other than a letter, digit,
"." , "_" or "-" becomes "_". A header names the stack file and the object.
The files are made from the stack, never the other way round: the stack
holds the script that runs, and editing a file here changes nothing.

tools/oxt/stack-scripts.sh runs this with the dumps that
ide-stack-dump.livecodescript writes:

  python3 tools/oxt/stack_scripts.py --dumps DUMPDIR [--check]

DUMPDIR holds one dump per stack, named after the stack's path with "/" and
" " made "_", plus ".txt". Without --check the files in stack-scripts/ are
written to match the stacks (and files of objects that are gone removed);
with --check nothing is written, and the exit status is 1 if any file would
change. tools/codebase-map uses the same functions for the map's site.
"""

import argparse
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, os.pardir, os.pardir))
FOLDER = 'stack-scripts'
SUFFIX = '.livecodescript'

OBJ_RE = re.compile(r'^== (.*)$')
ESC_RE = re.compile(r'\\(.)')
ESCAPES = {'\\': '\\', 'r': '\r', 'n': '\n', 't': '\t'}
SEG_RE = re.compile(r'^(\w+)(?: "(.*)")?(?: \(id (\d+)\))?$')
SAFE_RE = re.compile(r'[^A-Za-z0-9._-]+')


def unescape(value):
    """Undo ide-stack-dump.livecodescript's escapeValue, which writes a
    backslash, CR, LF and tab as \\\\, \\r, \\n and \\t."""
    return ESC_RE.sub(lambda m: ESCAPES.get(m.group(1), m.group(0)), value)


def dump_name(rel):
    """The file a stack's dump is in (make_dumps.sh's naming)."""
    return rel.replace('/', '_').replace(' ', '_') + '.txt'


def object_name(label):
    """The export name of the object a dump labels
    'stack "Main" > substack "Sub" > card (id 1002) > button "OK" (id 1004)'."""
    segs = [s.strip() for s in label.split(' > ')]
    stack = ''
    for s in segs:
        m = SEG_RE.match(s)
        if m and m.group(1).lower() in ('stack', 'substack'):
            stack = m.group(2) or ''
    name = 'stack_' + stack
    last = SEG_RE.match(segs[-1])
    if last and last.group(1).lower() not in ('stack', 'substack'):
        name += '_%s_id_%s' % (last.group(1).lower(), last.group(3) or '')
    return SAFE_RE.sub('_', name).strip('_') or 'stack'


def dump_scripts(dump_path):
    """Every object with a script in a stack dump, as (name, label, lines),
    in the dump's order. A name two objects share gets _2, _3... in that
    order, so each file is still the script of one object."""
    out, label, cur = [], None, None
    seen = collections.Counter()

    def flush():
        if label is not None and cur:
            name = object_name(label)
            seen[name] += 1
            if seen[name] > 1:
                name += '_%d' % seen[name]
            out.append((name, label, cur))

    with open(dump_path, encoding='utf-8', errors='replace') as f:
        for line in f:
            line = line.rstrip('\n')
            if line.startswith('| '):
                cur = (cur or []) + [unescape(line[2:])]
                continue
            if line == '|':
                cur = (cur or []) + ['']
                continue
            m = OBJ_RE.match(line)
            if m:
                flush()
                label, cur = m.group(1), None
    flush()
    return out


def render(rel, name, label, lines):
    return '\n'.join(['script "%s"' % name,
                      '-- Stack file: %s' % rel,
                      '-- Object: %s' % label,
                      '-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds',
                      '-- the script that runs, so change it there, not here.',
                      ''] + lines) + '\n'


def exports(dumps, stacks):
    """{path under stack-scripts/: text} for every dumped stack of stacks."""
    files = {}
    for rel in sorted(stacks):
        d = os.path.join(dumps, dump_name(rel))
        if not os.path.exists(d):
            continue
        for name, label, lines in dump_scripts(d):
            files['%s.bst/scripts/%s%s' % (rel, name, SUFFIX)] = render(rel, name, label, lines)
    return files


def binary_stacks(dumps):
    """The stacks make_dumps.sh dumped, from the dump of each. A stack the
    engine would not load has no dump and so no exports."""
    stacks = []
    for top in ('ide', 'ide-support'):
        for root, dirs, names in os.walk(os.path.join(REPO, top)):
            dirs.sort()
            for n in sorted(names):
                if n.endswith(('.livecode', '.rev', '.oxtstack')):
                    rel = os.path.relpath(os.path.join(root, n), REPO).replace(os.sep, '/')
                    if os.path.exists(os.path.join(dumps, dump_name(rel))):
                        stacks.append(rel)
    return stacks


def on_disk(folder):
    found = {}
    for root, dirs, names in os.walk(folder):
        for n in names:
            if n.endswith(SUFFIX):
                p = os.path.join(root, n)
                with open(p, encoding='utf-8', errors='replace', newline='') as f:
                    found[os.path.relpath(p, folder).replace(os.sep, '/')] = f.read()
    return found


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    ap.add_argument('--dumps', required=True)
    ap.add_argument('--check', action='store_true')
    a = ap.parse_args()
    folder = os.path.join(REPO, FOLDER)
    want = exports(a.dumps, binary_stacks(a.dumps))
    have = on_disk(folder)
    added = sorted(set(want) - set(have))
    gone = sorted(set(have) - set(want))
    changed = sorted(p for p in set(want) & set(have) if want[p] != have[p])
    if a.check:
        for label, paths in (('missing', added), ('no longer in a stack', gone), ('out of date', changed)):
            for p in paths:
                print('%s/%s: %s' % (FOLDER, p, label))
        if added or gone or changed:
            print('The scripts in %s/ do not match the binary stacks: run '
                  'tools/oxt/stack-scripts.sh <development engine> and commit the result '
                  '(CONTRIBUTING.md, "Binary stacks").' % FOLDER)
            return 1
        print('%s/: %d scripts of %d stacks, all as in the stacks'
              % (FOLDER, len(want), len({p.split('.bst/')[0] for p in want})))
        return 0
    for p in added + changed:
        path = os.path.join(folder, *p.split('/'))
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(want[p])
    for p in gone:
        os.remove(os.path.join(folder, *p.split('/')))
    for root, dirs, names in os.walk(folder, topdown=False):
        if root != folder and not os.listdir(root):
            os.rmdir(root)
    print('%s/: %d added, %d changed, %d removed' % (FOLDER, len(added), len(changed), len(gone)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
