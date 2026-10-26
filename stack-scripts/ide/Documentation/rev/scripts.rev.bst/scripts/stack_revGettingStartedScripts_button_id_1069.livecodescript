script "stack_revGettingStartedScripts_button_id_1069"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Centering a window on the screen Example" (id 1068) > button "Center Me!" (id 1069)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  centerMe
end mouseUp

on centerMe
  set the loc of this stack to the screenLoc
end centerMe
