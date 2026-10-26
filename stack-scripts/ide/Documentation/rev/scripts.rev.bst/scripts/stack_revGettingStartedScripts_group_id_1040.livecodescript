script "stack_revGettingStartedScripts_group_id_1040"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Combine random text strings Example" (id 1040)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--on closeField
  do "set the" && the short name of the target \
      && "of button" && quote & "Generate Insult" & quote \
      && "to" && quote & replaceText(target,return,space) & quote
end closeField
