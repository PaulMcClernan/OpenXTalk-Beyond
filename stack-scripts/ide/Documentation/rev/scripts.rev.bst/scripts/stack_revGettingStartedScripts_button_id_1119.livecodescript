script "stack_revGettingStartedScripts_button_id_1119"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Placing a font list into a menu Example" (id 1117) > button "Font" (id 1119)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
  answer "You chose" && quote & theItem & quote & "."
end menuPick
