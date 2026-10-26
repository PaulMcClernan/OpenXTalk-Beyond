script "stack_revGettingStartedScripts_button_id_1193"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Text menu: populating with content Example" (id 1191) > button "Text" (id 1193)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
  answer "You chose:" & return & tab & theItem
end menuPick
