script "stack_revPreferencesGUI_group_id_1104"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Object Sizes" (id 1009) > group "Object Sizes" (id 1104)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  if the text of the target is empty then
    beep
    put the short name of the target into tProp
    put the tProp of stack "revPreferences" into the target
  else
    pass closeField
  end if
end closeField

