script "stack_revGettingStartedScripts_group_id_1186"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Popping up a menu after a delay timer Example" (id 1186)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  set the textColor of char 1 to -1 of field "Example Text" to empty
  set the label of button "Color" to "Change color to green"
end preOpenBackground
