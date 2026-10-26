script "stack_revResourceCenter_field_id_579740"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "TextSearchBox" (id 109191) > group "mainContent" (id 109202) > group (id 584249) > group "Example" (id 577017) > field "Find Example" (id 579740)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField -- goes in Find field's script
  if me is empty then beep -- nothing to find
  else find the text of me -- "me" is the field
end returnInField
