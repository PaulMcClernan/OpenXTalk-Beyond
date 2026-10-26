script "stack_revGettingStartedScripts_field_id_1206"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Accepting only digit characters during data entry Example" (id 1205) > field "Digits Only" (id 1206)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown theKey
  if theKey is not a number then beep
  else pass keyDown
end keyDown
