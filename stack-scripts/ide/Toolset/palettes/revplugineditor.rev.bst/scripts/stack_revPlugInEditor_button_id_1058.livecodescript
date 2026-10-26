script "stack_revPlugInEditor_button_id_1058"
-- Stack file: ide/Toolset/palettes/revplugineditor.rev
-- Object: stack "revPlugInEditor" > card (id 1002) > group "Open plugin:" (id 1076) > group "Load:" (id 1027) > button "shutdown" (id 1058)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  hilite btn "Include in Plug-ins menu"
  enable btn "Include in Plug-ins menu"
  send "mouseUp" to btn "Include in Plug-ins menu"
  pass mouseUp
end mouseUp
