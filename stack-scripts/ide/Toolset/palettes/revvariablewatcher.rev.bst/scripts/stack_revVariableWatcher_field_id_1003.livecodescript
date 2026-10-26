script "stack_revVariableWatcher_field_id_1003"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002) > field "Values" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbardrag
  set the scroll of fld "Names" to the scroll of me
  set the scroll of fld "Watched" to the scroll of me
end scrollbardrag

on mouseDown
  selectVar (word 2 of the clickline)
end mouseDown

on selectionChanged
  set the hilitedLines of fld "names" to the hilitedLines of me
  selectVar (the hilitedLines of me)
end selectionChanged
