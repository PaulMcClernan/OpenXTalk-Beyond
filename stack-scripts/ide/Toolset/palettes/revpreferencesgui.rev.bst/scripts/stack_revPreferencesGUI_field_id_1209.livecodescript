script "stack_revPreferencesGUI_field_id_1209"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Property Profiles" (id 1012) > group "Property Profiles" (id 1207) > field "default profile name" (id 1209)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  global gREVTemplateMasterName
  if me is empty then put "Master" into me
  put me into gREVTemplateMasterName
  set the cREVTemplateMasterName of stack "revPreferences" to gREVTemplateMasterName
end closeField

on keyDown theKey
  if (charToNum(toUpper(theKey)) >= 65 and charToNum(toUpper(theKey)) <= 90) \
  or theKey is in "0123456789_" then pass keyDown else beep
end keyDown

on returnInField
  lock screen
  closeField
  select the text of me
  unlock screen
end returnInField

on enterInField
  returnInField
end enterInField
