script "CoreFieldUndoRecords"
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

-- A field's undo records must go when the field does. tperry2x's crash
-- (openxtalk.org, October 2026, p=25397): an undo that put a deletion back
-- while the field's text was selected over more than one line recorded a
-- second deletion for the same field, as putting the text back deleted
-- that selection first. In his stack the selection was autoTab's: on
-- macOS, Return had replaced the second field's text with a return, and an
-- autoTab field selects all its text as it takes the focus, which the undo
-- gives it. File > Close and Remove From Memory freed the field and only
-- one of its records, and the next keystroke in any field, which frees the
-- undo list, crashed. Here the stack goes as that command removes it
-- (delete stack), then a field of another stack gets the keystroke. On
-- 0.2.7-rc.6.5 for Linux each test crashes the engine there (signal 11;
-- valgrind shows the read of the freed field in ~MCUndonode, from
-- MCField::finsertnew, the frames of his crash report).

local sFields, sTyping

private command makeStacks pAutoTab
   local tName, tTop
   put "UndoRecordsTyping" into sTyping
   create stack sTyping
   create field "Q" in card 1 of stack sTyping
   set the rect of field "Q" of stack sTyping to 20, 20, 300, 60
   put "UndoRecordsFields" into sFields
   create stack sFields
   set the defaultStack to sFields
   put 91 into tTop
   repeat for each item tName in "A,B,C"
      create field tName
      set the rect of field tName to 133, tTop, 233, tTop + 42
      set the dontWrap of field tName to true
      set the autoTab of field tName to pAutoTab
      add 50 to tTop
   end repeat
   put "one" into field "A"
   put "two" & return & "lines" into field "B"
   put "three" into field "C"
end makeStacks

-- Delete the stack of the fields, then type into the other stack's field
private command typeAfterDeleting
   delete stack sFields
   set the defaultStack to sTyping
   select after text of field "Q"
   type "z"
   TestAssert "a keystroke in another stack after the stack was deleted", \
         the text of field "Q" is "z"
   delete stack sTyping
end typeAfterDeleting

on TestUndoInAFieldWithoutTheFocus
   TestSkipIfNot "wait"
   makeStacks true
   select char 1 to 3 of field "B"
   type numToChar(8)
   select after text of field "C"
   undo
   typeAfterDeleting
end TestUndoInAFieldWithoutTheFocus

-- Undone twice: the second undo makes the deletion again
on TestUndoTwiceInAFieldWithoutTheFocus
   TestSkipIfNot "wait"
   makeStacks true
   select char 1 to 3 of field "B"
   type numToChar(8)
   select after text of field "C"
   undo
   select after text of field "A"
   undo
   typeAfterDeleting
end TestUndoTwiceInAFieldWithoutTheFocus

-- Any field: two lines selected when the deletion is undone
on TestUndoWithLinesSelected
   TestSkipIfNot "wait"
   makeStacks false
   select char 1 to 3 of field "B"
   type numToChar(8)
   select line 1 to 2 of field "B"
   undo
   typeAfterDeleting
end TestUndoWithLinesSelected
