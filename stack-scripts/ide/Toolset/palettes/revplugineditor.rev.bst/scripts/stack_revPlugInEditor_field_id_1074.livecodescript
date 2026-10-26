script "stack_revPlugInEditor_field_id_1074"
-- Stack file: ide/Toolset/palettes/revplugineditor.rev
-- Object: stack "revPlugInEditor" > card (id 1002) > field "Message List" (id 1074)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  put currentPluginPath() into thePluginPath
  set the cREVLoadInfo[the value of the clickLine] of stack thePluginPath to \
      (word 2 of the clickLine is among the items of the hilitedLines of me)
  -- keep track of plugins needing to be saved
  if thePluginPath is not among the lines of the changedStacksList of this stack
  then set the changedStacksList of this stack \
      to the changedStacksList of this stack & thePluginPath & return
end mouseDown
