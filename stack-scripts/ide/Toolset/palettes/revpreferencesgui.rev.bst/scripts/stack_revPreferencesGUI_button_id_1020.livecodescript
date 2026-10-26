script "stack_revPreferencesGUI_button_id_1020"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > group "Shortcuts" (id 1019) > button "Context menus work on Rev dev stacks" (id 1020)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVPopups
  set the cRevPopups of stack "revPreferences" to the hilite of me
  put the hilite of me into gREVPopups
end mouseUp
