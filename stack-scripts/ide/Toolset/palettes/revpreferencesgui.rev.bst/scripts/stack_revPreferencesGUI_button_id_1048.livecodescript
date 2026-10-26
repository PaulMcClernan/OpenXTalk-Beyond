script "stack_revPreferencesGUI_button_id_1048"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > group "Files & Memory" (id 1041) > group "Closing Stacks" (id 1043) > group (id 1046) > button "Ask" (id 1048)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cASKDestroy of stack "revPreferences" to "ask"
end mouseUp
