script "stack_revGettingStartedScripts_group_id_1141"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Finding lines that are not common to two containers Example" (id 1141)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the initialText of field "List 1" into field "List 1"
  put the initialText of field "List 2" into field "List 2"
end preOpenBackground
