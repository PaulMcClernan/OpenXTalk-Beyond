script "stack_revPreferencesGUI_button_id_1368"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320) > button "controlSortOrder" (id 1368)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   revIDESetPBSortPreferences "pb_controlSort", the label of button "controlSortType", the label of me
end menuPick
