script "stack_revDocsShortcut_Reference_button_id_1008"
-- Stack file: ide/Documentation/rev/Shortcut Reference.rev
-- Object: stack "revDocsShortcut Reference" > card (id 1002) > button "Print Shortcut Reference" (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  revShowPrintDialog true,false
  revPrintField the long id of fld "doc"
end mouseUp
