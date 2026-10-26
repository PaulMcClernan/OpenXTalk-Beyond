script "stack_revPreferencesGUI_button_id_1522"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320) > button "textSize" (id 1522)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName   
   updatePreference "pb_textSize",the label of me
end menuPick

on returnInField
   updatePreference "pb_textSize",the label of me
end returnInField

on enterInField
   updatePreference "pb_textSize",the label of me
end enterInField

