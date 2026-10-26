script "stack_revResourceCenter_field_id_578779"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Acceptingonlydigitcharactersduringdataentry" (id 80380) > group "mainContent" (id 80390) > group (id 571864) > group "Example" (id 578778) > field "Digits Only" (id 578779)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown theKey
  if theKey is not a number then beep
  else pass keyDown
end keyDown
