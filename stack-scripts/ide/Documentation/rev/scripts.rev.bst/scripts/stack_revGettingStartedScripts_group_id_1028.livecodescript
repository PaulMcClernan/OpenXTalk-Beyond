script "stack_revGettingStartedScripts_group_id_1028"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Show or hide a scrollbar automatically as text is entered in a field Example" (id 1028)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the originalText of field "Example" into field "Example"
end preOpenBackground

on openBackGround
  select after text of field "Example"
end openBackGround
