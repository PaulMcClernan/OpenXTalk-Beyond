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

"""A Mac default button's label in the background (Skids, openxtalk.org
p=26152).

While the app is active a default button is drawn in the accent colour
with a white label. In the background the theme draws it as a plain
button (engine/src/buttondraw.cpp, drawstandardbutton: when
MCappisactive is false it sets WTHEME_STATE_SUPPRESSDEFAULT), but the
label of a default button with no text colour of its own was forced
white whether the app was active or not, so after a script launched
another app every default button was white on white. The label is white
only while the app is active, in each of the two places that decide it.

The IDE tour's last step, background-default
(tools/ci/ui-tour.livecodescript), measures it on the Mac: it brings the
Finder to the front, waits for a default button's face to turn grey, and
reads its label against the face at two heights. This test reads the
source, so that every platform's checks hold the rule and the step.

  python3 -m unittest discover -s tools/ci/tests
"""

import os
import re
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))


def read(*parts):
    with open(os.path.join(REPO, *parts), encoding='utf-8') as f:
        return f.read()


class TheThemeDrawsInTheControlsAppearance(unittest.TestCase):
    """engine/src/osxtheme.mm: each AppKit control drawn into an image is
    drawn with its own appearance as the current drawing appearance."""

    def test_every_control_draws_in_its_own_appearance(self):
        src = read('engine', 'src', 'osxtheme.mm')
        helper = src[src.index('static void MCMacThemeDrawInAppearance('):]
        helper = helper[:helper.index('\n}\n')]
        self.assertIn('[p_appearance performAsCurrentDrawingAppearance:p_draw];', helper)
        self.assertIn('[NSAppearance setCurrentAppearance:p_appearance];', helper)
        self.assertIn('[NSAppearance setCurrentAppearance:t_old];', helper)
        for draw, appearance in (
                ('[[t_slider cell] drawWithFrame:t_draw_rect inView:t_slider];', '[t_slider appearance]'),
                ('[t_scroller drawKnobSlotInRect:t_draw_rect highlight:NO];', '[t_scroller appearance]'),
                ('[t_progress drawRect:t_draw_rect];', '[t_progress appearance]'),
                ('[[t_control cell] drawWithFrame:t_draw_rect inView:nil];', 't_appearance')):
            at = src.index(draw)
            wrap = src.rindex('MCMacThemeDrawInAppearance(', 0, at)
            self.assertIn('MCMacThemeDrawInAppearance(%s, ^{' % appearance, src[wrap:at], draw)
            # nothing else between the wrapper and the draw
            self.assertLess(at - wrap, 120, draw)
            self.assertEqual(src.count(draw), 1, draw)


class TheDefaultLabelInTheBackground(unittest.TestCase):

    def setUp(self):
        source = read('engine', 'src', 'buttondraw.cpp')
        start = source.index('bool t_should_use_white_text = false;')
        self.branch = source[start:source.index('if (t_should_use_white_text)', start)]
        self.source = source

    def conditions(self):
        """Each `if (...)` that sets t_should_use_white_text, as one line."""
        found = re.findall(r'if \((.*?)\)\s*\n\s*(?:\{\s*\n\s*)?t_should_use_white_text = true;',
                           self.branch, re.S)
        return [' '.join(c.split()) for c in found]

    def test_white_only_while_active(self):
        conditions = self.conditions()
        # the glowing (hilited before macOS 11) or default button of the
        # usual height, and the default button with no text colour of its
        # own
        self.assertEqual(len(conditions), 2, conditions)
        for condition in conditions:
            self.assertIn('MCappisactive', condition)
            self.assertNotIn('!MCappisactive', condition)
        self.assertIn('!getcindex(DI_FORE, t_index) && !getpindex(DI_FORE, t_index)', conditions[1])

    def test_the_theme_suppresses_the_default_look_in_the_background(self):
        # what the label follows: in the background the default button is
        # drawn without its accent colour
        self.assertIn('if (!MCappisactive)\n\t\t\t\twinfo.state |= WTHEME_STATE_SUPPRESSDEFAULT;', self.source)

    def test_the_tour_measures_it(self):
        # The IDE tour runs the real IDE on the Mac, where the app is
        # active (its screenshots show the accent colour); the engine
        # tests run with no user interface (-ui), so they could not
        tour = read('tools', 'ci', 'ui-tour.livecodescript')
        steps = re.search(r'^constant kSteps = "([^"]+)"', tour, re.M).group(1).split(',')
        # last: it leaves the IDE in the background
        self.assertEqual(steps[-1], 'background-default')
        step = tour[tour.index('\non tour_background_default\n'):tour.index('\nend tour_background_default\n')]
        self.assertIn('if the platform is not "MacOS" then', step)
        self.assertIn('set the default of it to true', step)
        # put in the background by an app of the tour's own that has no
        # window (tourInactiveApp), not by launching the Finder: when the
        # Finder ran with no window (the dark run, the second on a
        # runner), the launch reopened it with one, over the stack
        # (rc.6.18's 99b dark shot on Apple silicon)
        self.assertNotIn('Finder', step)
        self.assertIn('launch tourInactiveApp()', step)
        # the face turned grey says the IDE is in the background; when it
        # never does the step fails rather than measuring an active button
        self.assertIn('if tourBgGrey(tFace) then exit repeat', step)
        self.assertIn('throw "the IDE could not be put in the background: '
                      'the default button\'s face is still" && tFace', step)
        # both rules: the usual height and a taller button
        self.assertIn('repeat for each item tHeight in "21,26"', step)
        # an ordinary button with the same label beside it: the default
        # button's label must be 200 from its face, or where the snapshot
        # draws even the ordinary one's label nearer than 230 (the dark
        # appearance's snapshot drew every face white), no more than 30
        # nearer than that one's. Never more than 200
        self.assertIn('create button "Plain"', step)
        self.assertIn('set the label of it to "OK"', step)
        self.assertIn('put tourBgLabel("OK") into tMeasure', step)
        self.assertIn('put tourBgLabel("Plain") into tPlain', step)
        self.assertIn('put min(200, item 4 of tPlain - 30) into tNeed', step)
        self.assertIn('if item 4 of tMeasure < tNeed then', step)
        self.assertIn('if tFails is not empty then throw', step)
        # in the dark appearance the snapshot draws the faces dark: the
        # theme draws a control in its own appearance, not the one the app
        # last drew in (rc.6.17 and rc.6.18 drew them white)
        self.assertIn('if $OXT_TOUR_APPEARANCE is "dark" and \\\n'
                      '            max(item 1 of tPlain, item 2 of tPlain, item 3 of tPlain) >= 160 then', step)
        self.assertLess(step.index('$OXT_TOUR_APPEARANCE is "dark"'), step.index('put min(200, item 4 of tPlain - 30)'))
        grey = tour[tour.index('function tourBgGrey pRGB'):tour.index('end tourBgGrey')]
        self.assertIn('min(item 1 of pRGB, item 2 of pRGB, item 3 of pRGB) <= 24', grey)
        # the snapshot is of the button as drawn now, with the app's state
        grab = tour[tour.index('command tourBgGrab'):tour.index('end tourBgGrab')]
        self.assertIn('import snapshot from button pButton of stack kBackground', grab)
        # the background is read from the default button's face
        self.assertIn('if tourBgGrey(tFace) then exit repeat', step)
        self.assertEqual(step.count('put tourBgFace("OK") into tFace'), 2)
        # the shot is of the stack: a mark of the brand's orange on its
        # card must be on the screen where the card has it, or something
        # covers the stack and the step fails (after the shot, which shows
        # what covered it)
        self.assertIn('create graphic "Mark"', step)
        self.assertIn('set the backgroundColor of it to kBgMark', step)
        shot = step.index('tourShotStack kBackground, "99b-background-default"')
        self.assertGreater(step.index('tourBgShown'), shot)
        shown = tour[tour.index('command tourBgShown'):tour.index('end tourBgShown')]
        self.assertIn('import snapshot from rect', shown)
        self.assertIn('throw "something covers the stack', shown)
        # the app quits when the step ends, failed or not
        self.assertIn('tourInactiveQuit', step)
        self.assertIn('pkill -x OXTTourInactive', tour[tour.index('command tourInactiveQuit'):
                                                        tour.index('end tourInactiveQuit')])
        app = tour[tour.index('function tourInactiveApp'):tour.index('end tourInactiveApp')]
        # an app of its own, with no window, built as the theme poster is
        self.assertIn('xcrun swiftc', app)
        self.assertIn('CFBundleExecutable', app)
        self.assertIn('throw "could not build the app', app)
        self.assertNotIn('NSWindow', app)
        # declared before the handlers that use them
        self.assertLess(tour.index('constant kBgMark'), tour.index('on tour_background_default'))
        self.assertLess(tour.index('local sInactiveApp'), tour.index('function tourInactiveApp'))
        self.assertLess(tour.index('constant kBackground = "OXT Tour Background"'), tour.index('on tour_background_default'))
        self.assertLess(tour.index('local sCtlChecks, sCtlFails, sPixWidth, sPixHeight, sPixData'),
                        tour.index('command tourBgGrab'))

if __name__ == '__main__':
    unittest.main()
