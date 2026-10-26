script "stack_revGettingStartedScripts_group_id_1022"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Inserting some text before each line in a field Example" (id 1022)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Prefix"
  put empty into field "List"
  select text of field "Prefix"
end preOpenBackground
