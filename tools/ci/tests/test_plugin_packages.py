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
