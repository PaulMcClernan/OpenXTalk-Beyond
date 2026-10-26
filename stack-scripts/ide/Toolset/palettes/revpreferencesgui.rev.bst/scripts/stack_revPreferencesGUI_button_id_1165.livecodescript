script "stack_revPreferencesGUI_button_id_1165"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Hide Palettes" (id 1165)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cSEHidePalettes of stack "revPreferences" to the hilite of me
end mouseUp
