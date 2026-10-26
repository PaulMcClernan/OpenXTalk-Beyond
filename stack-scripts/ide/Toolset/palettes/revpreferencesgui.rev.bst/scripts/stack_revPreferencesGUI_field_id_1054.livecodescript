script "stack_revPreferencesGUI_field_id_1054"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > group "Files & Memory" (id 1041) > field "Num Recent Files" (id 1054)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown pKey
  if pKey is not a number then beep
  else pass keyDown
end keyDown

on closeField
  set the cNumRecent of stack "revPreferences" to the text of me
 end closeField
