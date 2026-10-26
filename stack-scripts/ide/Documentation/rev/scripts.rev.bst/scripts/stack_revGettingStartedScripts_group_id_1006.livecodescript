script "stack_revGettingStartedScripts_group_id_1006"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Displaying a count down (non-blocking) Example" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeBackGround
  if "displayCurrentVerse" is in the pendingMessages then send "mouseUp" to button "Example"
end closeBackGround
