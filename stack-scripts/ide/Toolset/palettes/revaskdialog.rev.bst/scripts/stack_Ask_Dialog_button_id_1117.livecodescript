script "stack_Ask_Dialog_button_id_1117"
-- Stack file: ide/Toolset/palettes/revaskdialog.rev
-- Object: stack "Ask Dialog" > card (id 1002) > button "Cancel" (id 1117)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  lock messages
  close this stack
  revCleanUpAskDialog--won't get closeStack
  unlock messages
end mouseUp
