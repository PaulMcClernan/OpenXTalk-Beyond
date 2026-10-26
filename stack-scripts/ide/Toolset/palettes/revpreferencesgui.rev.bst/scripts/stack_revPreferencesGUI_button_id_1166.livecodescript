script "stack_revPreferencesGUI_button_id_1166"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Hide Message Box" (id 1166)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cSEHideMessageBox of stack "revPreferences" to the hilite of me
end mouseUp
