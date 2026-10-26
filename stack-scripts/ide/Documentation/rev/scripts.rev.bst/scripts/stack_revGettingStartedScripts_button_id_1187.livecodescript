script "stack_revGettingStartedScripts_button_id_1187"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Popping up a menu after a delay timer Example" (id 1186) > button "Colors" (id 1187)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theColor
  set the label of button "Color" to "Change color to" && toLower(theColor)
end menuPick
