script "stack_revGettingStartedScripts_field_id_1268"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Inserting line breaks to hard wrap text Example" (id 1265) > field "Line Length" (id 1268)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown theKey
  if theKey is not a number then beep
  else pass keyDown
end keyDown

on closeField
  if me is not an integer or me < 10 then
    beep
    put "20" into me
  end if
end closeField
