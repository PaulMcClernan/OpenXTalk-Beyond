script "stack_revGettingStartedScripts_group_id_1205"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Accepting only digit characters during data entry Example" (id 1205)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Digits Only"
end preOpenBackground

on openBackGround
  select text of field "Digits Only"
end openBackGround
