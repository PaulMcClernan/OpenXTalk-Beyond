script "stack_revPreferencesGUI_button_id_1022"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > group "Shortcuts" (id 1019) > button "UI edit script" (id 1022)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVUIScriptShortcut
  set the cREVUIScriptShortcut of stack "revPreferences" to the hilite of me
  put the hilite of me into gREVUIScriptShortcut
end mouseUp
