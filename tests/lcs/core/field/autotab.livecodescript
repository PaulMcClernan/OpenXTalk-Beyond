script "CoreFieldAutoTab"
/*
Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond.

OXT-Beyond is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

OXT-Beyond is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with OXT-Beyond.  If not see <http://www.gnu.org/licenses/>.  */

-- A field's autoTab ("tab on return"): Return on its last line moves the
-- focus to the next field, which selects its text. tperry2x's stack
-- (openxtalk.org, October 2026, p=25398) has three one-line fields with
-- dontWrap and autoTab: on macOS, Return after the text of the first
-- moved to the second, and Return there replaced the second's text with a
-- return instead of moving on, while from the third one Return went round
-- all three. In the Mac looks the engine set no caret position while a
-- field had a selection, so the second field decided by the caret of the
-- first, above it. Here Return goes round the three fields from the first
-- and from the third, in the system's look (where one loads: macOS's own
-- is a Mac look) and in each look the engine draws (the Macintosh look
-- follows the Mac's rule anywhere), and every field keeps its text. On
-- 0.2.7-rc.6.5 for Linux the Macintosh look fails: from the first field,
-- the second Return leaves the focus in the second field, with a return
-- for its text.

local sStack

private command makeFields
   local tName, tTop
   put "AutoTabFields" into sStack
   create stack sStack
   set the defaultStack to sStack
   put 91 into tTop
   repeat for each item tName in "A,B,C"
      create field tName
      set the rect of field tName to 133, tTop, 233, tTop + 21
      set the dontWrap of field tName to true
      set the autoTab of field tName to true
      add 50 to tTop
   end repeat
   put "one" into field "A"
   put "two" into field "B"
   put "three" into field "C"
end makeFields

-- The focused field's name and every field's text, as one line
private function fieldsNow
   local tName, tLine
   if word 1 of the focusedObject is "field" then
      put the short name of the focusedObject into tLine
   else
      put "(no field)" into tLine
   end if
   repeat for each item tName in "A,B,C"
      put space & tName & "=" & replaceText(the text of field tName of stack sStack, return, "\n") after tLine
   end repeat
   return tLine
end fieldsNow

private command checkRound pLook, pFirst, pOrder
   local tStep, tWant, tGot
   makeFields
   select after text of field pFirst
   repeat for each item tStep in pOrder
      type return
      put tStep && "A=one B=two C=three" into tWant
      put fieldsNow() into tGot
      TestAssert "in the look" && pLook & ", Return from" && pFirst && \
            "moves on to" && tStep && "and every field keeps its text (" & tGot & ")", tGot is tWant
   end repeat
   delete stack sStack
end checkRound

on TestAutoTabReturnGoesRound
   local tOldLook, tLook
   TestSkipIfNot "wait"
   put the lookAndFeel into tOldLook
   -- Appearance Manager is the system's look where it loads; elsewhere
   -- the look stays as it was
   repeat for each item tLook in "Appearance Manager,Macintosh,Windows 95,Motif"
      set the lookAndFeel to tLook
      checkRound the lookAndFeel, "A", "B,C,A,B"
      checkRound the lookAndFeel, "C", "A,B,C,A"
   end repeat
   set the lookAndFeel to tOldLook
end TestAutoTabReturnGoesRound
