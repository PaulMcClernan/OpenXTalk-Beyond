script "stack_revGettingStartedScripts_field_id_1062"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Repeating a string of text Example" (id 1059) > field "Number" (id 1062)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown theKey
  if theKey is not a number then beep
  else pass keyDown
end keyDown
