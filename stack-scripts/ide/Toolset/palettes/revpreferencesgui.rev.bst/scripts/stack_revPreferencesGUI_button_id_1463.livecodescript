script "stack_revPreferencesGUI_button_id_1463"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Dictionary" (id 1390) > button "useQuickDict" (id 1463)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cQuickDictionary of stack "revPreferences" to the hilite of me
  revUpdateAB
end mouseUp
