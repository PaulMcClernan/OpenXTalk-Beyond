script "stack_revGettingStartedScripts_group_id_1265"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Inserting line breaks to hard wrap text Example" (id 1265)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the originalText of field "Example Text" into field "Example Text"
  put "30" into field "Line Length"
end preOpenBackground
