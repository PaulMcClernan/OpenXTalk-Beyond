script "stack_revPreferencesGUI_button_id_1461"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Extras" (id 1402) > button "ScreenSharedMemory" (id 1461)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cScrnSharedMem of stack "revPreferences" to the hilite of me
   send hToggleScreenSharedMemory to stack "home"
end mouseUp
