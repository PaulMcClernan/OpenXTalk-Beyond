script "stack_revPreferencesGUI_button_id_1360"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320) > button "stackSortType" (id 1360)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   revIDESetPBSortPreferences "pb_stackSort", the label of me, the label of button "stackSortOrder"
   //updatePreference "pb_stackSortType",the label of me
end menuPick
