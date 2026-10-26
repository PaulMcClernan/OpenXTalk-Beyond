script "stack_revPlugInEditor_group_id_1010"
-- Stack file: ide/Toolset/palettes/revplugineditor.rev
-- Object: stack "revPlugInEditor" > card (id 1002) > group "Open plugin:" (id 1076) > group "Open as:" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put currentPluginPath() into thePluginPath
  if word 1 of the target is "button" -- just to make sure
  then set the cREVLoadInfo["mode"] of stack thePluginPath \
      to the short name of the target
  -- keep track of plugins needing to be saved
  if thePluginPath is not among the lines of the changedStacksList of this stack
  then set the changedStacksList of this stack \
      to the changedStacksList of this stack & thePluginPath & return
end mouseUp
