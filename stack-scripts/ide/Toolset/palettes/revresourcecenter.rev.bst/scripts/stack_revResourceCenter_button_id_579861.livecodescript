script "stack_revResourceCenter_button_id_579861"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Poppingupamenuafteradelaytimer" (id 80366) > group "mainContent" (id 80378) > group (id 579865) > group "Example" (id 577036) > button "Colors" (id 579861)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theColor
  set the label of button "Color" to "Change color to" && toLower(theColor)
end menuPick
