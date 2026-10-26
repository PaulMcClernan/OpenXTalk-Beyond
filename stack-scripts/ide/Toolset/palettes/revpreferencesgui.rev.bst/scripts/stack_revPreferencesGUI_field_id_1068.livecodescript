script "stack_revPreferencesGUI_field_id_1068"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > field "gridSize" (id 1068)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  if me is not a number then put 2 into me
  set the gridSize to me
  set the cGridSize of stack "revPreferences" to me
  lock messages
  set the thumbposition of sb "grid" to the endValue of sb "grid" - me
  unlock messages
end closeField

on enterInField
  closeField
  select the text of the target
end enterInField

on returnInField
  enterInField
end returnInField
