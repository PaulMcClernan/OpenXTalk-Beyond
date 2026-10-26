script "stack_revPreferencesGUI_button_id_1324"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320) > button "stackSortOrder" (id 1324)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   revIDESetPBSortPreferences "pb_stackSort", the label of button "stackSortType", the label of me
end menuPick
