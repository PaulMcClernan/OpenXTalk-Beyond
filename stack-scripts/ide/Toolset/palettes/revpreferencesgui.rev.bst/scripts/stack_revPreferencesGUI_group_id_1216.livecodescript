script "stack_revPreferencesGUI_group_id_1216"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "App Browser" (id 1013) > group "double-click" (id 1216)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  lock messages
  set the menuHistory of the target to lineOffset(the label of the target, the text of the target)
  unlock messages
end mouseDown
