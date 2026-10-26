script "stack_revResourceCenter_group_id_578821"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Combinerandomtextstrings" (id 109204) > group "mainContent" (id 109225) > group (id 109220) > group "Example" (id 578821)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--on closeField
  do "set the" && the short name of the target \
      && "of button" && quote & "Generate Insult" & quote \
      && "to" && quote & replaceText(target,return,space) & quote
end closeField
