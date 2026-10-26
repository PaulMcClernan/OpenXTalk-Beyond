script "stack_revResourceCenter_field_id_578795"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Insertinglinebreakstohardwraptext" (id 80438) > group "mainContent" (id 80450) > group (id 578797) > group "Example" (id 578792) > field "Line Length" (id 578795)
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
