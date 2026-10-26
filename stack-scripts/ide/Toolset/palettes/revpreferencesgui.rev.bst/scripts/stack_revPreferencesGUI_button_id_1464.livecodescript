script "stack_revPreferencesGUI_button_id_1464"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > button "frameSize" (id 1464)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the revPaletteFrameSize of stack "revPreferences" to the label of me
end mouseUp
