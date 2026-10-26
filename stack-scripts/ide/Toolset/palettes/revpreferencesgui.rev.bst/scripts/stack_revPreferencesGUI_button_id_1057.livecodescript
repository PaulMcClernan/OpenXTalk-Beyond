script "stack_revPreferencesGUI_button_id_1057"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > group "Files & Memory" (id 1041) > group "Stack File Property Preservation" (id 1055) > button "Preserve Stack Version" (id 1057)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cPreserveStackVersion of stack "revPreferences" to the hilite of me
end mouseUp
