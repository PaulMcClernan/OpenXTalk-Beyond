script "stack_Print_Dialog_button_id_1031"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002) > button "Print" (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  applySettings
  set the dialogData to empty
  close this stack
end mouseUp
