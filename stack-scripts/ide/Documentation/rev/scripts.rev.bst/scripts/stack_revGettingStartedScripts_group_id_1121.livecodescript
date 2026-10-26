script "stack_revGettingStartedScripts_group_id_1121"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Drag drop a background color onto an object Example" (id 1121)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  set the backgroundColor of graphic "Ball" to empty
  set the label of graphic "Ball" to empty
end preOpenBackground
