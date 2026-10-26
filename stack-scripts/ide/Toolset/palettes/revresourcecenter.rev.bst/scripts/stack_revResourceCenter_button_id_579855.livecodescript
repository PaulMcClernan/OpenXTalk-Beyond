script "stack_revResourceCenter_button_id_579855"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Updatingamenuwithalistofopenwindows" (id 100278) > group "mainContent" (id 100298) > group (id 584259) > group "Example" (id 577034) > group "Menubar" (id 579854) > button "Window" (id 579855)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
  answer "You chose:" & return & tab & theItem
end menuPick 
