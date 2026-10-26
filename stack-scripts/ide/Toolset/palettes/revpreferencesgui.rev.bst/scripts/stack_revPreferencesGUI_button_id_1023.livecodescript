script "stack_revPreferencesGUI_button_id_1023"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > group "Shortcuts" (id 1019) > button "opt edit script shortcut" (id 1023)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVScriptShortcut
  set the cREVScriptShortcut of stack "revPreferences" to the hilite of me
  put the hilite of me into gREVScriptShortcut
  set the enabled of button "UI edit script" of cd "general" to the hilite of me
end mouseUp
