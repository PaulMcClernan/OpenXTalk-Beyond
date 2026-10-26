script "stack_revGettingStartedScripts_group_id_1240"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Speaking an alert message Example" (id 1240)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the defaultAlert of field "Speech" into field "Speech"
end preOpenBackground
