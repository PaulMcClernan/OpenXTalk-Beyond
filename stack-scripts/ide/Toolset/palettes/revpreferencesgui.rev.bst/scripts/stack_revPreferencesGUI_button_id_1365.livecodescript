script "stack_revPreferencesGUI_button_id_1365"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320) > button "cardSortType" (id 1365)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName 
   revIDESetPBSortPreferences "pb_cardSort", the label of me, the label of button "cardSortOrder"
end menuPick
