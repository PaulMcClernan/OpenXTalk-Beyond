script "stack_revSuppressMessages_button_id_1011"
-- Stack file: ide/Toolset/palettes/revmessagewatcher.rev
-- Object: stack "revMessageWatcher" > substack "revSuppressMessages" > card (id 1002) > button "Delete" (id 1011)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  get the hilitedLines of field "Suppressed Messages"
  if it is not empty
  then delete line it of field "Suppressed Messages"
end mouseUp
