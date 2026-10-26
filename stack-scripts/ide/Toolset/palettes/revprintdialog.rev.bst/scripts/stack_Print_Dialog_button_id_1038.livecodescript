script "stack_Print_Dialog_button_id_1038"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002) > button "Cancel" (id 1038)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  restorePreviousPrinterSettings
  set the dialogData to "cancel"
  close this stack
end mouseUp
