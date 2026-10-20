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

"""The changelog fragments of changelog/, and folding them into
CHANGELOG.md.

  python3 tools/ci/changelog.py check
  python3 tools/ci/changelog.py fold [--dry-run]

Every pull request used to add its lines to the end of the "Unreleased"
section of CHANGELOG.md, so each merge left every other open pull request
in conflict on that one file, and the merge of main that settled it built
all three platforms again. Now a pull request writes its lines to a file
of its own, changelog/<name>.md (any name no other pull request uses:
its branch's, or its number once it has one), in CHANGELOG.md's own form,
one "- " line per change ending with the pull request's number:

  - Tools palette: long names shrink or wrap instead of being cut off (#168)

check (CI checks, on every pull request and push): every fragment holds
at least one line, every line that is not empty starts with "- ", none is
a heading, and CHANGELOG.md has at most one "## Unreleased" section.

fold (the pull request that sets a release's version, before it renames
"## Unreleased" to the version; BUILDING.md, "Making a release"): appends
the fragments' lines to the end of "## Unreleased" (made above the newest
release's section when there is none), in the order the fragments came
into the repository (the commit that added each, from git; by name when
git cannot tell, as in a shallow clone), and deletes the fragments. So
CHANGELOG.md reads exactly as it did when the lines were added to it by
hand. changelog/README.md is not a fragment. Only the Python 3 standard
library is used.
"""

import argparse
import os
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
CHANGELOG = 'CHANGELOG.md'
FRAGMENTS = 'changelog'
README = 'README.md'
UNRELEASED = '## Unreleased'


class ChangelogError(Exception):
    pass


def fragment_names(repo):
    folder = os.path.join(repo, FRAGMENTS)
    if not os.path.isdir(folder):
        return []
    return sorted(f for f in os.listdir(folder)
                  if f.endswith('.md') and f != README
                  and os.path.isfile(os.path.join(folder, f)))


def fragment_lines(repo, name):
    """The "- " lines of a fragment; an error for anything else in it."""
    path = os.path.join(repo, FRAGMENTS, name)
    with open(path, encoding='utf-8') as f:
        text = f.read()
    lines = []
    for number, line in enumerate(text.splitlines(), 1):
        line = line.rstrip()
        if not line:
            continue
        if not line.startswith('- ') or not line[2:].strip():
            raise ChangelogError('%s/%s, line %d: not a "- " line: %r'
                                 % (FRAGMENTS, name, number, line))
        lines.append(line)
    if not lines:
        raise ChangelogError('%s/%s holds no "- " line' % (FRAGMENTS, name))
    return lines


def read_changelog(repo):
    with open(os.path.join(repo, CHANGELOG), encoding='utf-8') as f:
        return f.read().split('\n')


def unreleased_count(lines):
    return sum(1 for line in lines if line.rstrip() == UNRELEASED)


def check(repo):
    """Every problem found, as a list of messages (empty when none)."""
    problems = []
    for name in fragment_names(repo):
        try:
            fragment_lines(repo, name)
        except ChangelogError as e:
            problems.append(str(e))
    if unreleased_count(read_changelog(repo)) > 1:
        problems.append('%s has more than one "%s" section' % (CHANGELOG, UNRELEASED))
    return problems


def added_at(repo, name):
    """When the fragment came into the repository: the commit time of the
    first commit that added it, or None when git cannot tell (not
    committed yet, no git, a shallow clone without that commit)."""
    try:
        out = subprocess.run(
            ['git', 'log', '--diff-filter=A', '--follow', '--format=%ct', '--',
             FRAGMENTS + '/' + name],
            cwd=repo, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
            universal_newlines=True, check=True).stdout.split()
    except (OSError, subprocess.CalledProcessError):
        return None
    return int(out[-1]) if out else None


def ordered(repo, names):
    """Fragments in the order they came in; uncommitted ones last, and by
    name among those git cannot date."""
    def key(name):
        t = added_at(repo, name)
        return (t is None, t or 0, name)
    return sorted(names, key=key)


def folded(lines, new_lines):
    """CHANGELOG.md's lines with new_lines at the end of its Unreleased
    section (made above the first release's section if there is none)."""
    lines = list(lines)
    if unreleased_count(lines) == 0:
        first = next((i for i, line in enumerate(lines) if line.startswith('## ')), None)
        if first is None:
            raise ChangelogError('%s has no "## " section to put "%s" above'
                                 % (CHANGELOG, UNRELEASED))
        lines[first:first] = [UNRELEASED, '']
    start = next(i for i, line in enumerate(lines) if line.rstrip() == UNRELEASED)
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith('## ')),
               len(lines))
    # after the section's last line that is not empty
    last = end - 1
    while last > start and not lines[last].strip():
        last -= 1
    if last == start:
        # an empty section: its lines start after one empty line, and the
        # empty lines it had stay below them, before the next section
        insert = [''] + new_lines
        if start + 1 >= len(lines) or lines[start + 1].strip():
            insert.append('')
        lines[start + 1:start + 1] = insert
    else:
        lines[last + 1:last + 1] = new_lines
    return lines


def fold(repo, dry_run=False):
    """Fold every fragment into CHANGELOG.md and delete it; the lines
    added, in order."""
    problems = check(repo)
    if problems:
        raise ChangelogError('\n'.join(problems))
    names = ordered(repo, fragment_names(repo))
    new_lines = [line for name in names for line in fragment_lines(repo, name)]
    if not new_lines:
        return []
    lines = folded(read_changelog(repo), new_lines)
    if not dry_run:
        with open(os.path.join(repo, CHANGELOG), 'w', encoding='utf-8', newline='\n') as f:
            f.write('\n'.join(lines))
        for name in names:
            os.remove(os.path.join(repo, FRAGMENTS, name))
    return new_lines


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    parser.add_argument('--repo', default=REPO, help=argparse.SUPPRESS)
    sub = parser.add_subparsers(dest='command')
    sub.required = True
    sub.add_parser('check', help='check the fragments and CHANGELOG.md')
    p = sub.add_parser('fold', help='fold the fragments into CHANGELOG.md')
    p.add_argument('--dry-run', action='store_true',
                   help='print the lines, change nothing')
    args = parser.parse_args(argv)
    try:
        if args.command == 'check':
            problems = check(args.repo)
            for problem in problems:
                print('ERROR: ' + problem)
            if problems:
                return 1
            print('%d changelog fragment(s), all well formed' % len(fragment_names(args.repo)))
            return 0
        added = fold(args.repo, args.dry_run)
        for line in added:
            print(line)
        print('%s %d line(s) under "%s"' % ('Would add' if args.dry_run else 'Added',
                                            len(added), UNRELEASED))
        return 0
    except ChangelogError as e:
        print('ERROR: %s' % e)
        return 1


if __name__ == '__main__':
    sys.exit(main())
