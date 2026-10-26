script "stack_revPlugInEditor_button_id_1056"
-- Stack file: ide/Toolset/palettes/revplugineditor.rev
-- Object: stack "revPlugInEditor" > card (id 1002) > group "Open plugin:" (id 1076) > group "Load:" (id 1027) > button "chosen" (id 1056)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  hilite btn "Include in Plug-ins menu"
  disable btn "Include in Plug-ins menu"
  pass mouseUp
end mouseUp
