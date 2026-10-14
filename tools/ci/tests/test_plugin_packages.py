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

"""The extension packages of the xTalk Assistant and the xTalk MCP Bridge
for other xTalks' IDEs (tools/plugins/build-plugin-packages.py).

It checks that both packages build, are the same bytes when built twice,
and pass the checks the Extension Manager makes before it installs a
package; that the checks refuse what the Extension Manager refuses; that
each package's compatibility stack is named as the plugin's main stack
loads it (its kCompat and the file it looks for) and dispatches the
message OXT-Beyond's menu bar dispatches; that no plugin folder in
ide/Extensions has a compatibility stack of its own (so OXT-Beyond's own
copy never loads one); and that the bridge's package carries the
assistant's files the bridge loads. The compatibility stack's behavior is
tested on an engine by tests/lcs/plugins.

  python3 -m unittest discover -s tools/ci/tests
"""

import importlib.util
import io
import os
import re
import tempfile
import unittest
import zipfile

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
BUILDER = os.path.join(REPO, 'tools', 'plugins', 'build-plugin-packages.py')
MENUBAR = os.path.join(REPO, 'ide', 'Toolset', 'palettes', 'menubar', 'revmenubar.livecodescript')


def load_builder():
    spec = importlib.util.spec_from_file_location('build_plugin_packages', BUILDER)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def zip_of(entries):
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, 'w') as zf:
        for name, data in entries:
            zf.writestr(name, data)
    return buffer.getvalue()


MANIFEST = (b'<package version="0.0"><name>a.b.c</name><title>T</title><author>A</author>'
            b'<version>1</version><type>plugin</type></package>')


class PluginPackages(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.builder = load_builder()
        cls.out = tempfile.mkdtemp(prefix='plugin-packages-')
        cls.paths = {}
        for plugin in cls.builder.PLUGINS:
            cls.paths[plugin['name']] = cls.builder.build(plugin, '9.9.9-test', cls.out)

    def read(self, name):
        with open(self.paths[name], 'rb') as f:
            return f.read()

    def test_packages_install(self):
        for name in self.paths:
            with self.subTest(name):
                self.assertEqual(self.builder.check_package(self.read(name)), [])

    def test_same_bytes_twice(self):
        again = tempfile.mkdtemp(prefix='plugin-packages-')
        for plugin in self.builder.PLUGINS:
            with self.subTest(plugin['name']):
                path = self.builder.build(plugin, '9.9.9-test', again)
                with open(path, 'rb') as f:
                    self.assertEqual(f.read(), self.read(plugin['name']))

    def test_version_is_the_packages(self):
        for name in self.paths:
            with self.subTest(name):
                zf = zipfile.ZipFile(io.BytesIO(self.read(name)))
                self.assertIn(b'<version>9.9.9-test</version>', zf.read('manifest.xml'))
                self.assertTrue(self.paths[name].endswith('-9.9.9-test.lce'))
                self.assertEqual(zf.namelist()[0], 'manifest.xml')

    def test_compat_stack_matches_main_stack(self):
        with open(MENUBAR, encoding='utf-8') as f:
            menubar = f.read()
        for plugin in self.builder.PLUGINS:
            with self.subTest(plugin['name']):
                zf = zipfile.ZipFile(io.BytesIO(self.read(plugin['name'])))
                compat_file = plugin['main'] + '-compat.livecodescript'
                compat = zf.read(compat_file).decode('utf-8')
                self.assertNotRegex(compat, r'@[A-Z_]+@')
                self.assertTrue(compat.startswith('script "%s-compat"' % plugin['name']))
                main = zf.read(plugin['main'] + '.livecodescript').decode('utf-8')
                # The main stack loads it by this name and from this file
                self.assertIn('constant kCompat = "%s-compat"' % plugin['name'], main)
                self.assertIn('"/%s"' % compat_file, main)
                self.assertIn('dispatch "xtpcStart" to stack kCompat', main)
                self.assertIn('dispatch "xtpcStop" to stack kCompat', main)
                # The message is the one OXT-Beyond's menu bar dispatches,
                # and the main stack has it
                pick = 'dispatch "%s" to stack "%s"' % (plugin['menu_pick'], plugin['name'])
                self.assertIn(pick, menubar)
                self.assertRegex(main, r'(?m)^(on|command) %s\b' % plugin['menu_pick'])
                self.assertIn('put tab & "%s" & return after tDevelopment' % plugin['title'], menubar)
                self.assertIn('constant kMenuPick = "%s"' % plugin['menu_pick'], compat)
                self.assertIn('constant kMenuTitle = "%s"' % plugin['title'], compat)

    def test_no_compat_stack_in_oxt_beyond(self):
        for plugin in self.builder.PLUGINS:
            folder = os.path.join(self.builder.EXTENSIONS, plugin['name'])
            with self.subTest(plugin['name']):
                self.assertFalse(os.path.exists(os.path.join(folder, plugin['main'] + '-compat.livecodescript')))

    def test_bridge_carries_the_assistant(self):
        zf = zipfile.ZipFile(io.BytesIO(self.read('org.openxtalk.plugin.mcpbridge')))
        names = zf.namelist()
        for name in ('xtalkassistant-core.livecodescript', 'xtalkassistant-build.livecodescript', 'xtalk-guide.md'):
            self.assertIn('xtalkassistant/' + name, names)
        bridge = zf.read('mcpbridge.livecodescript').decode('utf-8')
        self.assertIn('constant kBundledAssistantFolder = "xtalkassistant"', bridge)
        tools = zf.read('mcpbridge-tools.livecodescript').decode('utf-8')
        # The files mcbEnsureParts loads and the guide it reads
        for name in re.findall(r'sAssistantFolder & "/([^"]+)"', tools):
            self.assertIn('xtalkassistant/' + name, names)
        self.assertIn('mcp/server.js', names)
        # The copy Claude runs is made from the package's own server
        self.assertIn('constant kStableServerFile = "mcp/server.js"', bridge)
        compat = zf.read('mcpbridge-compat.livecodescript').decode('utf-8')
        self.assertRegex(compat, r'(?m)^function xtpcStableCopy pSource, pName, pOnlyIfThere$')

    def test_one_server_per_ide(self):
        """In another IDE the bridge's server has that IDE's name and bridge
        file: the compatibility stack gives them, the bridge asks for them,
        and the desktop extension's manifest has the lines it rewrites."""
        zf = zipfile.ZipFile(io.BytesIO(self.read('org.openxtalk.plugin.mcpbridge')))
        compat = zf.read('mcpbridge-compat.livecodescript').decode('utf-8')
        for fn in ('xtpcServerName', 'xtpcBridgeFile'):
            self.assertRegex(compat, r'(?m)^function %s$' % fn)
        bridge = zf.read('mcpbridge.livecodescript').decode('utf-8')
        tools = zf.read('mcpbridge-tools.livecodescript').decode('utf-8')
        self.assertIn('dispatch function "xtpcServerName" to stack kCompat', bridge)
        self.assertIn('dispatch function "xtpcBridgeFile" to stack kCompat', bridge)
        self.assertIn('dispatch function "xtpcBridgeFile" to stack "org.openxtalk.plugin.mcpbridge-compat"', tools)
        self.assertRegex(tools, r'(?m)^function mcbDesktopConfigText pOld, pName, pServerPath, pBridgeFile$')
        # The server reads the file it is told
        server = zf.read('mcp/server.js').decode('utf-8')
        self.assertIn('process.env.OXT_MCP_BRIDGE_FILE', server)
        # mcbManifestLine's lines, each once in the manifest
        manifest = zf.read('mcp/manifest.json').decode('utf-8')
        for line in ('"name": "oxt-beyond"', '"display_name": "OXT-Beyond"', '"args": ["${__dirname}/server.js"]'):
            with self.subTest(line):
                self.assertEqual(manifest.count(line), 1)
        self.assertIn('constant kServerName = "oxt-beyond"', bridge)
        self.assertIn('return quote & "display_name" & quote & ": " & quote & "OXT-Beyond" & quote', bridge)
        self.assertIn('return quote & "args" & quote & ": [" & quote & "${__dirname}/server.js" & quote & "]"', bridge)

    def test_host_name(self):
        """Every stack that names the IDE asks a compatibility stack for its
        name, which the stack answers."""
        for plugin in self.builder.PLUGINS:
            zf = zipfile.ZipFile(io.BytesIO(self.read(plugin['name'])))
            compat = zf.read(plugin['main'] + '-compat.livecodescript').decode('utf-8')
            self.assertRegex(compat, r'(?m)^function xtpcHostName$')
            for name in zf.namelist():
                if not name.endswith('.livecodescript') or name.endswith('-compat.livecodescript'):
                    continue
                text = zf.read(name).decode('utf-8')
                for fn in sorted(set(re.findall(r'\b((?:xta|mcb)HostName)\(\)', text))):
                    with self.subTest(name=name, fn=fn):
                        self.assertRegex(text, r'(?m)^private function %s$' % fn)
                        self.assertIn('dispatch function "xtpcHostName" to stack tStack', text)
                        self.assertIn('%s-compat' % plugin['name'], text)

    def test_release_files(self):
        """--release writes the files and SHA256SUMS the release's
        OXT-Beyond-plugins artifact has (tools/ci/release_assets.py)."""
        spec = importlib.util.spec_from_file_location(
            'release_assets', os.path.join(REPO, 'tools', 'ci', 'release_assets.py'))
        release_assets = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(release_assets)
        version = '9.9.9-test'
        artifacts = tempfile.mkdtemp(prefix='plugin-release-')
        folder = os.path.join(artifacts, 'OXT-Beyond-plugins')
        self.assertEqual(self.builder.main(['--release', '--version', version, '--out', folder]), 0)
        want = [names for artifact, _, names in release_assets.expected(version)
                if artifact == 'OXT-Beyond-plugins']
        self.assertEqual(len(want), 1)
        self.assertEqual(sorted(os.listdir(folder)), sorted(want[0] + ['SHA256SUMS']))
        problems = release_assets.Problems()
        digests = release_assets.check_artifact(folder, 'OXT-Beyond-plugins', want[0], problems)
        self.assertEqual(list(problems), [])
        self.assertEqual(sorted(digests), sorted(want[0]))
        # The same packages as without --release, under the release's names
        for plugin in self.builder.PLUGINS:
            with open(os.path.join(folder, self.builder.release_name(plugin, version)), 'rb') as f:
                self.assertEqual(f.read(), self.read(plugin['name']))

    def test_check_refuses(self):
        check = self.builder.check_package
        main = b'script "a.b.c"\n'
        self.assertEqual(check(zip_of([('manifest.xml', MANIFEST), ('c.livecodescript', main)])), [])
        self.assertTrue(check(b'not a zip'))
        self.assertTrue(check(zip_of([('c.livecodescript', main)])))
        self.assertTrue(check(zip_of([('dir/', b''), ('manifest.xml', MANIFEST), ('c.livecodescript', main)])))
        self.assertTrue(check(zip_of([('manifest.xml', MANIFEST.replace(b'<title>T</title>', b'')),
                                      ('c.livecodescript', main)])))
        # A second stack at the root not named <main>-<part>
        self.assertTrue(check(zip_of([('manifest.xml', MANIFEST), ('c.livecodescript', main),
                                      ('other.livecodescript', b'script "x"\n')])))
        self.assertEqual(check(zip_of([('manifest.xml', MANIFEST), ('c.livecodescript', main),
                                       ('c-part.livecodescript', b'script "x"\n'),
                                       ('sub/other.livecodescript', b'script "y"\n')])), [])
        # The main stack's name is the manifest's
        self.assertTrue(check(zip_of([('manifest.xml', MANIFEST), ('c.livecodescript', b'script "x"\n')])))


if __name__ == '__main__':
    unittest.main()
