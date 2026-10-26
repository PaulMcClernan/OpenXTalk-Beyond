script "stack_revPreferencesGUI_button_id_1218"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "App Browser" (id 1013) > group "double-click" (id 1216) > button "command double-click" (id 1218)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pWhich
  set the cABCommandDoubleClick[revSelObjectType()] of stack "revPreferences" to pWhich
end menuPick
