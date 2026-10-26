script "stack_revResourceCenter_group_id_578773"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Limitingthenumberofcharactersduringdataentry" (id 80353) > group "mainContent" (id 80363) > group (id 571863) > group "Example" (id 578773)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openBackGround
  put empty into field "Example"
  select text of field "Example"
end openBackGround
