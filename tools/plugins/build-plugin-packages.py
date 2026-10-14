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

"""Package the xTalk Assistant and the xTalk MCP Bridge as extension
packages (.lce) that the Extension Manager of any IDE built on LiveCode
Community 9 installs: LiveCode Community 9.x, OpenXTalk, HyperXTalk and
OXT-Beyond itself.

The packages are made from the plugins' own folders in ide/Extensions, the
one copy of their code; nothing of them is kept twice. A package adds only:

  - <main>-compat.livecodescript, made from plugin-compat.livecodescript.in
    (in this folder): the menu item and the Script Editor handlers that
    another IDE lacks. OXT-Beyond's own copy of the plugin has no such
    file, and its main stack loads it only when it is there.
  - for the bridge, a folder xtalkassistant/ with the assistant's core,
    build library and guide, which the bridge uses. In OXT-Beyond they are
    in the assistant's folder beside the bridge's; a package is installed
    in a folder of its own, named with its version, so it carries them.
  - the version: the package's manifest says OXT-Beyond's version
    (ide/.version), so that each release's packages install over the
    last's. The manifests in ide/Extensions keep theirs.

A package is checked as the Extension Manager checks it before it installs
it (extensionValidateLCEPackage and extensionFetchSourceFromFolder of
extensions/script-libraries/extension-utils, the same in LiveCode Community
9.6.3): every file at the root of the zip or in a folder under it, never a
folder entry first; manifest.xml at the root with a name, version, author,
type and title; one main stack at the root, every other stack at the root
named <main>-<part>. The zip is the same bytes for the same sources: the
files in order, with one fixed time.

  python3 tools/plugins/build-plugin-packages.py [--out DIR] [--version V]
  python3 tools/plugins/build-plugin-packages.py --release --out DIR --version V
  python3 tools/plugins/build-plugin-packages.py --check PACKAGE.lce ...

--release names the packages as a release's files
(OXT-Beyond-<version>-xtalk-assistant-plugin.lce and
OXT-Beyond-<version>-mcp-bridge-plugin.lce) and writes a SHA256SUMS beside
them: the artifact "OXT-Beyond-plugins" that .github/workflows/release.yml
makes and tools/ci/release_assets.py checks.

Tested by tools/ci/tests/test_plugin_packages.py.
"""

import argparse
import hashlib
import io
import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
EXTENSIONS = os.path.join(REPO, 'ide', 'Extensions')
COMPAT_TEMPLATE = os.path.join(HERE, 'plugin-compat.livecodescript.in')

# One fixed time for every file of a package (zip times have no zone and
# start in 1980)
ZIP_TIME = (2026, 1, 1, 0, 0, 0)

# The plugins that are packaged. "menu_pick" is the message OXT-Beyond's
# menu bar dispatches to the main stack for the plugin's entry in
# Development > Plugins (ide/Toolset/palettes/menubar/revmenubar.livecodescript);
# "title" is that entry's text. "extra" maps a folder in the package to the
# files of another plugin's folder it carries. "release" is the end of the
# package's name among a release's files (OXT-Beyond-<version><release>,
# --release; the ASSETS of tools/ci/release_assets.py name the same): the
# Extension Manager reads the plugin's name and version from the manifest,
# and of the file's name only that it ends in .lce.
PLUGINS = [
    {
        'name': 'org.openxtalk.plugin.xtalkassistant',
        'main': 'xtalkassistant',
        'title': 'xTalk Assistant',
        'menu_pick': 'xtalkAssistantMenuPick',
        'release': '-xtalk-assistant-plugin.lce',
        'extra': {},
    },
    {
        'name': 'org.openxtalk.plugin.mcpbridge',
        'main': 'mcpbridge',
        'title': 'xTalk MCP Bridge',
        'menu_pick': 'mcpBridgeMenuPick',
        'release': '-mcp-bridge-plugin.lce',
        # mcbAssistantFolder in mcpbridge.livecodescript (its
        # kBundledAssistantFolder), mcbEnsureParts and the guide's file in
        # mcpbridge-tools.livecodescript
        'extra': {
            'xtalkassistant': (
                'org.openxtalk.plugin.xtalkassistant',
                ['xtalkassistant-core.livecodescript',
                 'xtalkassistant-build.livecodescript',
                 'xtalk-guide.md'],
            ),
        },
    },
]

# What a package never takes from a plugin's folder
SKIPPED = {'.DS_Store', 'Thumbs.db'}

STACK_RE = re.compile(r'^.*\.livecode(script)?$')


def oxt_version():
    with open(os.path.join(REPO, 'ide', '.version'), encoding='utf-8') as f:
        return f.read().strip()


def plugin_files(folder):
    """The files of a plugin's folder, as (path in the package, path on
    disk), sorted, with forward slashes."""
    found = []
    for root, dirs, files in os.walk(folder):
        dirs[:] = sorted(d for d in dirs if not d.startswith('.'))
        for name in sorted(files):
            if name in SKIPPED or name.startswith('.'):
                continue
            full = os.path.join(root, name)
            rel = os.path.relpath(full, folder).replace(os.sep, '/')
            found.append((rel, full))
    return found


def compat_script(plugin):
    with open(COMPAT_TEMPLATE, encoding='utf-8') as f:
        text = f.read()
    values = {
        '@COMPAT_STACK@': plugin['name'] + '-compat',
        '@MAIN_STACK@': plugin['name'],
        '@MENU_TITLE@': plugin['title'],
        '@MENU_PICK@': plugin['menu_pick'],
    }
    for key, value in values.items():
        text = text.replace(key, value)
    left = re.findall(r'@[A-Z_]+@', text)
    if left:
        raise SystemExit('plugin-compat.livecodescript.in: unknown %s' % ', '.join(sorted(set(left))))
    return text.encode('utf-8')


def package_manifest(path, version):
    """The plugin's manifest.xml with the package's version, written as the
    one line the plugins' manifests are."""
    with open(path, encoding='utf-8') as f:
        text = f.read()
    new, count = re.subn(r'<version>[^<]*</version>', '<version>%s</version>' % version, text, count=1)
    if count != 1:
        raise SystemExit('%s: no <version> element' % path)
    return new.encode('utf-8')


def release_name(plugin, version):
    return 'OXT-Beyond-%s%s' % (version, plugin['release'])


def build(plugin, version, out_dir, file_name=None):
    folder = os.path.join(EXTENSIONS, plugin['name'])
    entries = {}
    for rel, full in plugin_files(folder):
        if rel == 'manifest.xml':
            entries[rel] = package_manifest(full, version)
        else:
            with open(full, 'rb') as f:
                entries[rel] = f.read()
    compat = plugin['main'] + '-compat.livecodescript'
    if compat in entries:
        raise SystemExit('%s: %s is made here, not kept in the plugin' % (plugin['name'], compat))
    entries[compat] = compat_script(plugin)
    for sub, (other, names) in plugin['extra'].items():
        for name in names:
            path = os.path.join(EXTENSIONS, other, name)
            if not os.path.isfile(path):
                raise SystemExit('%s: %s is missing' % (plugin['name'], path))
            with open(path, 'rb') as f:
                entries[sub + '/' + name] = f.read()

    # manifest.xml first: the Extension Manager refuses a zip whose first
    # entry is a folder, and reads the manifest by name
    order = ['manifest.xml'] + sorted(k for k in entries if k != 'manifest.xml')
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, 'w', zipfile.ZIP_DEFLATED) as zf:
        for name in order:
            info = zipfile.ZipInfo(name, ZIP_TIME)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            zf.writestr(info, entries[name])
    data = buffer.getvalue()
    problems = check_package(data)
    if problems:
        raise SystemExit('%s: %s' % (plugin['name'], '; '.join(problems)))
    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, file_name or '%s-%s.lce' % (plugin['name'], version))
    with open(path, 'wb') as f:
        f.write(data)
    return path


def write_sums(paths, out_dir):
    """SHA256SUMS over the packages, as sha256sum writes it and as
    tools/ci/release_assets.py checks a release artifact."""
    lines = []
    for path in sorted(paths, key=os.path.basename):
        with open(path, 'rb') as f:
            lines.append('%s  %s' % (hashlib.sha256(f.read()).hexdigest(), os.path.basename(path)))
    with open(os.path.join(out_dir, 'SHA256SUMS'), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(lines) + '\n')


def check_package(data):
    """What the Extension Manager would refuse in the package (its bytes):
    empty when it installs."""
    problems = []
    try:
        zf = zipfile.ZipFile(io.BytesIO(data))
    except zipfile.BadZipFile:
        return ['not a zip archive']
    names = zf.namelist()
    if not names:
        return ['empty archive']
    # extensionValidateLCEPackage: "files must be at root"
    if names[0].endswith('/'):
        problems.append('the first entry is a folder')
    if 'manifest.xml' not in names:
        problems.append('no manifest.xml at the root')
        return problems
    if not any(STACK_RE.match(n) for n in names):
        problems.append('no stack or module')
    try:
        root = ET.fromstring(zf.read('manifest.xml'))
    except ET.ParseError as error:
        return problems + ['manifest.xml is not XML: %s' % error]
    if root.tag != 'package':
        problems.append('manifest.xml is not a <package>')
    fields = {}
    for field in ('name', 'version', 'author', 'type', 'title'):
        element = root.find(field)
        if element is None or not (element.text or '').strip():
            problems.append('manifest.xml has no %s' % field)
        else:
            fields[field] = element.text.strip()
    # extensionFetchSourceFromFolder, over the root of the installed folder
    # (files() is not recursive): one main stack, the rest <main>-<part>
    stacks = sorted(n for n in names if '/' not in n and STACK_RE.match(n))
    main = None
    if len(stacks) > 1:
        for candidate in stacks:
            stem = candidate.rsplit('.', 1)[0]
            others = [s for s in stacks if s != candidate]
            if all(s.startswith(stem + '-') for s in others):
                main = candidate
                break
        if main is None:
            problems.append('no main stack that every other root stack is named after')
    elif stacks:
        main = stacks[0]
    else:
        problems.append('no stack at the root')
    # The IDE names the extension after its main stack (the short name of
    # the stack, its script line)
    if main is not None and 'name' in fields:
        first = zf.read(main).decode('utf-8', 'replace').lstrip('﻿').splitlines()[0]
        match = re.match(r'^script "([^"]*)"', first)
        if not match:
            problems.append('%s does not begin with a script line' % main)
        elif match.group(1) != fields['name']:
            problems.append('%s is stack "%s", not the manifest\'s %s' % (main, match.group(1), fields['name']))
    return problems


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    parser.add_argument('--out', default=os.path.join(REPO, '_build', 'plugins'),
                        help='where the packages go (default: _build/plugins)')
    parser.add_argument('--version', default=None,
                        help="the packages' version (default: ide/.version)")
    parser.add_argument('--release', action='store_true',
                        help="name the packages as a release's files and write SHA256SUMS "
                             '(the release workflow)')
    parser.add_argument('--check', nargs='+', metavar='PACKAGE',
                        help='check packages instead of building them')
    args = parser.parse_args(argv)
    if args.check:
        failed = False
        for path in args.check:
            with open(path, 'rb') as f:
                problems = check_package(f.read())
            print('%s: %s' % (path, '; '.join(problems) if problems else 'OK'))
            failed = failed or bool(problems)
        return 1 if failed else 0
    version = args.version or oxt_version()
    if not re.match(r'^[0-9A-Za-z][0-9A-Za-z.+-]*$', version):
        raise SystemExit('not a version: %r' % version)
    paths = []
    for plugin in PLUGINS:
        name = release_name(plugin, version) if args.release else None
        paths.append(build(plugin, version, args.out, name))
        print(paths[-1])
    if args.release:
        write_sums(paths, args.out)
    return 0


if __name__ == '__main__':
    sys.exit(main())
