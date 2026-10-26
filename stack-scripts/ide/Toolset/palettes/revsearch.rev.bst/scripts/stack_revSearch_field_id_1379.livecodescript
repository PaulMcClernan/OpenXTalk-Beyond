script "stack_revSearch_field_id_1379"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group (id 1384) > field "Type" (id 1379)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMessageID, lMoving

on mouseDown
  put true into lMoving
  lock screen
  set the hilitedLines of fld "name" to the hilitedLines of me
  set the hilitedLines of fld "card" to the hilitedLines of me
  set the hilitedLines of fld "stack" to the hilitedLines of me
  set the scroll of fld "name" to the scroll of me
  set the scroll of fld "card" to the scroll of me
  set the scroll of fld "stack" to the scroll of me
  unlock screen
end mouseDown

on selectionChanged
  lock screen
  set the hilitedLines of fld "name" to the hilitedLines of me
  set the hilitedLines of fld "card" to the hilitedLines of me
  set the hilitedLines of fld "stack" to the hilitedLines of me
  set the scroll of fld "name" to the scroll of me
  set the scroll of fld "card" to the scroll of me
  set the scroll of fld "stack" to the scroll of me
  set the thumbPosition of sb "results" to the scroll of me
  unlock screen
end selectionChanged

on mouseMove
  if lMoving then
    lock messages
    lock screen
    set the hilitedLines of fld "stack" to the hilitedLines of me
    set the hilitedLines of fld "name" to the hilitedLines of me
    set the hilitedLines of fld "card" to the hilitedLines of me
    set the scroll of fld "stack" to the scroll of me
    set the scroll of fld "name" to the scroll of me
    set the scroll of fld "card" to the scroll of me
    set the thumbPosition of sb "results" to the scroll of me
    unlock screen
    unlock messages
  end if
end mouseMove

on mouseUp 
  put false into lMoving
  pass mouseUp
end mouseUp

on mouseRelease
  put false into lMoving
  pass mouseRelease
end mouseRelease

on scrollBarDrag
  lock messages
  lock screen
  set the scroll of fld "stack" to the scroll of me
  set the scroll of fld "name" to the scroll of me
  set the scroll of fld "card" to the scroll of me
  set the thumbPosition of sb "results" to the scroll of me
  unlock screen
  unlock messages
end scrollBarDrag
