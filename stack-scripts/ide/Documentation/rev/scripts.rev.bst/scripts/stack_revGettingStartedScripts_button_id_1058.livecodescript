script "stack_revGettingStartedScripts_button_id_1058"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Updating a menu with a list of open Windows Example" (id 1055) > group "Menubar" (id 1057) > button "Window" (id 1058)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
  answer "You chose:" & return & tab & theItem
end menuPick 
