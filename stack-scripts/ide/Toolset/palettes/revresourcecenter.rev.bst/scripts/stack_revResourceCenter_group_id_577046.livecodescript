script "stack_revResourceCenter_group_id_577046"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Displayingacountdown(non-blocking)" (id 80215) > group "mainContent" (id 80225) > group (id 584269) > group "Example" (id 577046)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeBackGround
  if "displayCurrentVerse" is in the pendingMessages then send "mouseUp" to button "Example"
end closeBackGround
