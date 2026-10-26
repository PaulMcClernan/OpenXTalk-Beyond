script "stack_revResourceCenter_button_id_579907"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Convertingarelativepathtoanabsolutepath" (id 102575) > group "mainContent" (id 102592) > group (id 579908) > group "Example" (id 577048) > button "Browse..." (id 579907)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer folder "Please choose a file:"
  if it is not empty then put it into field "Path"
end mouseUp
