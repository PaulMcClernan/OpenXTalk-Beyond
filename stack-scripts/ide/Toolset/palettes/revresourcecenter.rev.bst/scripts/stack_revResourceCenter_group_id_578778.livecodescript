script "stack_revResourceCenter_group_id_578778"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Acceptingonlydigitcharactersduringdataentry" (id 80380) > group "mainContent" (id 80390) > group (id 571864) > group "Example" (id 578778)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Digits Only"
end preOpenBackground

on openBackGround
  select text of field "Digits Only"
end openBackGround
