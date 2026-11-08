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
"""A widget installed or uninstalled shows, or goes, in the Tools palette
at once, in either look (bwmilby, forum, 2026-11-07). The palette's
subscription to ideExtensionsChanged was commented out, so it took a
switch of look or a restart. It is subscribed again, as in LiveCode, and
the palette is made again only when the widgets it shows have changed
(a library loaded, or the batch at start-up, leaves it as it is); a palette
closed meanwhile is made again when it opens. The IDE tour's step
tools-widget-install and ide/tests/tools/widgetinstall run it on an engine.

  python3 -m unittest discover -s tools/ci/tests
"""

import os
import re
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
PALETTE = os.path.join(REPO, 'ide', 'Toolset', 'palettes', 'tools', 'revtools.livecodescript')
TOUR = os.path.join(REPO, 'tools', 'ci', 'ui-tour.livecodescript')
IDE_TEST = os.path.join(REPO, 'ide', 'tests', 'tools', 'widgetinstall.livecodescript')
EXTENSIONS = os.path.join(REPO, 'ide', 'Toolset', 'libraries', 'revideextensionlibrary.livecodescript')


def read(path):
    with open(path, encoding='utf-8') as f:
        return f.read()


def handler(text, name):
    m = re.search(r'^[ \t]*(?:private[ \t]+)?(?:command|on|function)[ \t]+%s\b(.*?)^[ \t]*end[ \t]+%s\b'
                  % (re.escape(name), re.escape(name)), text, re.M | re.S)
    if m is None:
        raise AssertionError('no handler ' + name)
    return m.group(1)


def code(body):
    return '\n'.join(line.split('--', 1)[0] for line in body.splitlines())


class WidgetInstallTest(unittest.TestCase):
    def setUp(self):
        self.text = read(PALETTE)

    def test_palette_hears_extensions_changed(self):
        body = code(handler(self.text, 'registerForMessages'))
        self.assertRegex(body, re.compile(r'^\s*revIDESubscribe "ideExtensionsChanged"\s*$', re.M))
        self.assertNotIn('-- revIDESubscribe "ideExtensionsChanged"', handler(self.text, 'registerForMessages'))

    def test_extension_library_still_sends_it(self):
        self.assertIn('ideMessageSend "ideExtensionsChanged"', code(read(EXTENSIONS)))

    def test_rebuilds_only_when_the_widgets_changed(self):
        body = code(handler(self.text, 'ideExtensionsChanged'))
        gate = body.index('if not toolsWidgetsChanged() then exit ideExtensionsChanged')
        self.assertLess(gate, body.index('generatePalette'))
        self.assertLess(body.index('generatePalette'), body.index('layoutPalette'))

    def test_signature_reads_what_the_palette_reads(self):
        sig = code(handler(self.text, 'toolsWidgetSignature'))
        self.assertIn('put revIDEWidgets() into tData', sig)
        self.assertIn('sort lines of tKeys', sig)
        for key in ('version', 'title', 'icon', 'svgicon'):
            self.assertIn('tData[tKey]["%s"]' % key, sig)
        changed = code(handler(self.text, 'toolsWidgetsChanged'))
        self.assertIn('return toolsWidgetSignature() is not sToolsWidgetSig', changed)

    def test_both_looks_record_what_they_were_made_with(self):
        # the classic look, after the modern look's early exit
        classic = code(handler(self.text, 'generatePalette'))
        self.assertLess(classic.index('tmGenerate'), classic.index('put toolsWidgetSignature() into sToolsWidgetSig'))
        modern = code(handler(self.text, 'tmGenerate'))
        self.assertLess(modern.index('put toolsWidgetSignature() into sToolsWidgetSig'), modern.index('put tmViewsData() into tData'))

    def test_reopened_palette_catches_up(self):
        body = code(handler(self.text, 'openStack'))
        self.assertRegex(body, r'if there is a group "contents" of me and toolsWidgetsChanged\(\) then\s+generatePalette')
        self.assertLess(body.index('toolsWidgetsChanged()'), body.index('layoutpalette'))

    def test_script_local_declared_above_its_readers(self):
        decl = self.text.index('local sToolsWidgetSig')
        for name in ('openStack', 'toolsWidgetsChanged', 'generatePalette', 'tmGenerate'):
            self.assertLess(decl, re.search(r'^(?:private )?(?:on|command|function) %s\b' % name, self.text, re.M).start())

    def test_tour_step(self):
        tour = read(TOUR)
        steps = [l for l in tour.splitlines() if l.startswith('constant kSteps')][0].split('"')[1].split(',')
        self.assertEqual(steps.index('tools-widget-install'), steps.index('tools-modern-default') + 1)
        body = handler(tour, 'tour_tools_widget_install')
        for needle in ('revIDEExtensionUnload kTourWidgetID', 'revIDEExtensionReload kTourWidgetID',
                       'repeat for each item tLook in "modern,classic"', 'close stack "revTools"',
                       'kTourWidgetLibrary', 'tourTmFinish "tools-widget-install"', 'tourTmReset'):
            self.assertIn(needle, body)
        # the Spinner is loaded again whatever fails
        after = body.split('end try', 1)[1]
        self.assertIn('revIDEExtensionReload kTourWidgetID', after)

    def test_ide_test(self):
        text = read(IDE_TEST)
        for name in ('TestModernLook', 'TestClassicLook', 'TestWhileClosed', 'TestLibraryLeavesPalette'):
            handler(text, name)
        self.assertIn('revIDEExtensionReload kWidget', code(handler(text, 'TestTeardown')))


if __name__ == '__main__':
    unittest.main()
