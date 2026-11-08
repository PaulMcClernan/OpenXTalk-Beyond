script "ProjectBrowserHilite"
/*
Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond, a fork of LiveCode Community.

LiveCode is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

-- OXT-Beyond: the colour of a selected Project Browser row's names
-- (revIDEHilitedTextColor). In the web IDE they are white on the blue
-- hilite (littlenemo, openxtalk.org p=26169; seth's decision of
-- 2026-11-08): they were the accentColor, a blue, on it. The desktops
-- answer as before.

on TestHilitedNamesAreWhiteOnTheWeb
   TestAssert "web: white on the Project Browser's hilite", \
         revIDEHilitedTextColor(revIDEColor("dataView_hiliteColor"), true) is "255,255,255"
   TestAssert "web: white on a light hilite too", revIDEHilitedTextColor("255,221,0", true) is "255,255,255"
   TestAssert "web: white for a colour given by name", revIDEHilitedTextColor("blue", true) is "255,255,255"
end TestHilitedNamesAreWhiteOnTheWeb

on TestHilitedNamesOnADesktopAreAsBefore
   if the platform is "Linux" then
      TestAssert "Linux: black on a light hilite", revIDEHilitedTextColor("255,221,0", false) is "0,0,0"
      TestAssert "Linux: white on a dark one", revIDEHilitedTextColor("119,33,111", false) is "255,255,255"
   else
      TestAssert "macOS and Windows: the accent colour, as before", \
            revIDEHilitedTextColor("48,160,209", false) is revIDEColor("dataView_TextHiliteColor")
   end if
   TestAssert "a colour given by name: the accent colour, as before", \
         revIDEHilitedTextColor("blue", false) is revIDEColor("dataView_TextHiliteColor")
   if not revEnvironmentIsWeb() then
      TestAssert "with no pWeb, this desktop answers as before", \
            revIDEHilitedTextColor("48,160,209") is revIDEHilitedTextColor("48,160,209", false)
   end if
end TestHilitedNamesOnADesktopAreAsBefore
