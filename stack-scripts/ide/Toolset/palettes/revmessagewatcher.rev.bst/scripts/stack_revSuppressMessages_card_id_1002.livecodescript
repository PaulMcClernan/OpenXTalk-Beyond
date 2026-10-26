script "stack_revSuppressMessages_card_id_1002"
-- Stack file: ide/Toolset/palettes/revmessagewatcher.rev
-- Object: stack "revMessageWatcher" > substack "revSuppressMessages" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
  repeat with i = 1 to the number of buttons
    set the hilite of button i to false
  end repeat
  set the hilite of button "IDE Messages" to the suppressIDE of stack "revPreferences"
  put the suppressedMessages of stack "revPreferences" into field "Suppressed Messages"
  get the the suppressedActions of stack "revPreferences"
  repeat for each line l in it
    set the hilite of button l to true
  end repeat
  get the the suppressedTypes of stack "revPreferences"
  repeat for each line l in it
    set the hilite of button l to true
  end repeat
end preOpenCard
