script "stack_revResourceCenter_field_id_578774"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Limitingthenumberofcharactersduringdataentry" (id 80353) > group "mainContent" (id 80363) > group (id 571863) > group "Example" (id 578773) > field "Example" (id 578774)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown theKey
  if the length of me >= 5 then beep
  else pass keyDown
end keyDown
