script "stack_revGettingStartedScripts_group_id_1166"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Limiting the number of characters during data entry Example" (id 1166)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openBackGround
  put empty into field "Example"
  select text of field "Example"
end openBackGround
