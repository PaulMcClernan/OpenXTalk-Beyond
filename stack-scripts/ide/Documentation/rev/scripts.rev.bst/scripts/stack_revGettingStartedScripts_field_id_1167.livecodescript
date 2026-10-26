script "stack_revGettingStartedScripts_field_id_1167"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Limiting the number of characters during data entry Example" (id 1166) > field "Example" (id 1167)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown theKey
  if the length of me >= 5 then beep
  else pass keyDown
end keyDown
