script "stack_revResourceCenter_button_id_579916"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "convertinganabsolutepathtoarelativepath" (id 104775) > group "mainContent" (id 104792) > group (id 584271) > group "Example" (id 577049) > button "Browse..." (id 579916)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer folder "Please choose a file:"
  if it is not empty then put it into field "Path"
end mouseUp
