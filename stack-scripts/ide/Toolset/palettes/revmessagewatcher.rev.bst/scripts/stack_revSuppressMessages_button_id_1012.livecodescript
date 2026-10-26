script "stack_revSuppressMessages_button_id_1012"
-- Stack file: ide/Toolset/palettes/revmessagewatcher.rev
-- Object: stack "revMessageWatcher" > substack "revSuppressMessages" > card (id 1002) > button "OK" (id 1012)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the suppressIDE of stack "revPreferences" to the hilite of button "IDE Messages"
  set the suppressedMessages of stack "revPreferences" to field "Suppressed Messages"
  get empty
  repeat with i = 1 to the number of buttons in group "Action"
    if the hilite of button i of group "Action"
    then put the short name of button i of group "Action" & cr after it
  end repeat
  delete last char of it
  set the suppressedActions of stack "revPreferences" to it
  get empty
  repeat with i = 1 to the number of buttons in group "Handler Type"
    if the hilite of button i of group "Handler Type"
    then put the short name of button i of group "Handler Type" & cr after it
  end repeat
  delete last char of it
  set the suppressedTypes of stack "revPreferences" to it
  close this stack
end mouseUp
