script "stack_revMessageWatcher_field_id_1003"
-- Stack file: ide/Toolset/palettes/revmessagewatcher.rev
-- Object: stack "revMessageWatcher" > card (id 1002) > field "Messages" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  selectMessage word 2 of the clickLine
end mouseUp

on mouseDoubleUp
 put the text of fld "object name" into tObject
 if tObject <> "" then edit the script of tObject
end mouseDoubleUp
