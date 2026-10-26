script "stack_revSuppressMessages_button_id_1010"
-- Stack file: ide/Toolset/palettes/revmessagewatcher.rev
-- Object: stack "revMessageWatcher" > substack "revSuppressMessages" > card (id 1002) > button "Add..." (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  ask question "Message to add?"
  if it is not empty then
    if field "Suppressed Messages" is empty
    then put it into field "Suppressed Messages"
    else put cr & it after field "Suppressed Messages"
  end if
end mouseUp
