script "stack_revMenuManager_button_id_4881"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > group "Menu Button Controls" (id 4879) > button "Edit Script" (id 4881)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVActiveMenuButton
  revCheckNameChanged
  --edit script of menu button
  edit script of gREVActiveMenuButton
  pass mouseUp
end mouseUp
