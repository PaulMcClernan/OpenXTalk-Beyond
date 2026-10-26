script "stack_revPlugInEditor_button_id_1098"
-- Stack file: ide/Toolset/palettes/revplugineditor.rev
-- Object: stack "revPlugInEditor" > card (id 1002) > button "Include in Plug-ins menu" (id 1098)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put currentPluginPath() into thePluginPath
  set the cREVLoadInfo["inMenu"] of stack thePluginPath \
      to the hilite of me
  -- keep track of plugins needing to be saved
  if thePluginPath is not among the lines of the changedStacksList of this stack
  then set the changedStacksList of this stack to the changedStacksList of this stack & thePluginPath & return
end mouseUp
