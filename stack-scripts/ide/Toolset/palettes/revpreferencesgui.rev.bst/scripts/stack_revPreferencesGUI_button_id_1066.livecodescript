script "stack_revPreferencesGUI_button_id_1066"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > button "Rulers" (id 1066)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cREVRulerMeasurement of stack "revPreferences" to the label of me
  if "revRulersH" is among the lines of the openStacks then revCalculateRulers
end mouseUp
