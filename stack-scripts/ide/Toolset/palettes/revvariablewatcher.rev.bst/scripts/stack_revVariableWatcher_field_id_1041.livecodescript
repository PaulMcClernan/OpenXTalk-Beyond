script "stack_revVariableWatcher_field_id_1041"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002) > field "contentsArrayKey" (id 1041)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbardrag
  set the scroll of fld "contentsArrayValue" to the scroll of me
  set the scroll of fld "contentsArrayKey" to the scroll of me
end scrollbardrag
