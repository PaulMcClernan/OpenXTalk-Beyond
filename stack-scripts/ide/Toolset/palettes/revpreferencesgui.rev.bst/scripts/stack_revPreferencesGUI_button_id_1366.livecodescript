script "stack_revPreferencesGUI_button_id_1366"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320) > button "cardSortOrder" (id 1366)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   revIDESetPBSortPreferences "pb_cardSort", the label of button "cardSortType", the label of me
end menuPick


