script "stack_revSearch_field_id_1388"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group (id 1384) > field "Stack" (id 1388)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMessageID

on mouseDown
  hSelectionUpdate
  lock screen
  set the hilitedLines of fld "type" to the hilitedLines of me
  set the hilitedLines of fld "name" to the hilitedLines of me
  set the hilitedLines of fld "card" to the hilitedLines of me
  set the scroll of fld "type" to the scroll of me
  set the scroll of fld "name" to the scroll of me
  set the scroll of fld "card" to the scroll of me
  unlock screen
end mouseDown

on selectionChanged
  lock screen
  set the hilitedLines of fld "type" to the hilitedLines of me
  set the hilitedLines of fld "name" to the hilitedLines of me
  set the hilitedLines of fld "card" to the hilitedLines of me
  set the scroll of fld "type" to the scroll of me
  set the scroll of fld "name" to the scroll of me
  set the scroll of fld "card" to the scroll of me
  set the thumbPosition of sb "results" to the scroll of me
  unlock screen
end selectionChanged

on hSelectionUpdate
  lock screen
  set the hilitedLines of fld "type" to the hilitedLines of me
  set the hilitedLines of fld "name" to the hilitedLines of me
  set the hilitedLines of fld "card" to the hilitedLines of me
  set the scroll of fld "type" to the scroll of me
  set the scroll of fld "name" to the scroll of me
  set the scroll of fld "card" to the scroll of me
  set the thumbPosition of sb "results" to the scroll of me
  unlock screen
  if "hSelectionUpdate" is not in the pendingMessages then send "hSelectionUpdate" to me in 1 milliseconds
  put the result into lMessageID
end hSelectionUpdate

on mouseUp 
  cancel lMessageID
  pass mouseUp
end mouseUp

on mouseRelease
  cancel lMessageID
  pass mouseRelease
end mouseRelease

on scrollBarDrag
  lock messages
  lock screen
  set the scroll of fld "type" to the scroll of me
  set the scroll of fld "name" to the scroll of me
  set the scroll of fld "card" to the scroll of me
  set the thumbPosition of sb "results" to the scroll of me
  unlock screen
  unlock messages
end scrollBarDrag
