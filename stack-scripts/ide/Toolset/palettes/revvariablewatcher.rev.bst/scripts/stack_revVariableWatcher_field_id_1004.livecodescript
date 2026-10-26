script "stack_revVariableWatcher_field_id_1004"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002) > field "Names" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  selectVar (word 2 of the clickline)
end mouseDown

on selectionChanged
  set the hilitedLines of fld "values" to the hilitedLines of me
  selectVar (the hilitedLines of me)
end selectionChanged

on scrollBarDrag x
  set the scroll of fld "values" to x
end scrollBarDrag
