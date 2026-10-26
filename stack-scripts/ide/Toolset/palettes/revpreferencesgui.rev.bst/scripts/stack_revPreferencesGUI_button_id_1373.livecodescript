script "stack_revPreferencesGUI_button_id_1373"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > button "Clear Msg Box History" (id 1373)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --clear msg box history (mx 200 lines)
   answer information "Clear the stored message box history?" with "Cancel" or "OK" titled "Clear Msg Box History"
   if it = "Cancel" then exit to top
   get the customKeys of stack "revPreferences"  --all custom properties
   if "cRevSingleLineHistory" is in it then set the cRevSingleLineHistory of stack "revPreferences" to empty  --clear
   if "cRevMultipleLineHistory" is in it then set the cRevMultipleLineHistory of stack "revPreferences" to empty
   if "IDESingleLineMessageHistory" is in it then set the IDESingleLineMessageHistory of stack "revPreferences" to empty
   if "IDEMultipleLinesMessageHistory" is in it then set the IDEMultipleLinesMessageHistory of stack "revPreferences" to empty
   answer "The stored message box history has been cleared." with "OK" titled "Clear Msg Box History"
end mouseUp
