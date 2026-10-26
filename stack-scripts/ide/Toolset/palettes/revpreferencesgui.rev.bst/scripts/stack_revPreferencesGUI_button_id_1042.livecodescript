script "stack_revPreferencesGUI_button_id_1042"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > group "Files & Memory" (id 1041) > button "add extension" (id 1042)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cREVExtension of stack "revPreferences" to the hilite of me
end mouseUp
