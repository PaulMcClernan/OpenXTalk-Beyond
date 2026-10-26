script "stack_revPreferencesGUI_button_id_1503"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "External script editor" (id 1503)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cExternalScriptEditor of stack "revPreferences" to the hilite of me
end mouseUp
