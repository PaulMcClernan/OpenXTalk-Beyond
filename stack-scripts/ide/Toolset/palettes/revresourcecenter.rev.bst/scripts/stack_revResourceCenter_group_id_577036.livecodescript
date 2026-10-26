script "stack_revResourceCenter_group_id_577036"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Poppingupamenuafteradelaytimer" (id 80366) > group "mainContent" (id 80378) > group (id 579865) > group "Example" (id 577036)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  set the textColor of char 1 to -1 of field "Example Text" to empty
  set the label of button "Color" to "Change color to green"
end preOpenBackground
