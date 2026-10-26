script "stack_revGettingStartedScripts_field_id_1221"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Rounding a number up to a ceiling Example" (id 1219) > field "Example Number" (id 1221)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField -- goes in Find field's script
  if me is empty then beep -- nothing to find
  else find the text of me -- "me" is the field
end returnInField
