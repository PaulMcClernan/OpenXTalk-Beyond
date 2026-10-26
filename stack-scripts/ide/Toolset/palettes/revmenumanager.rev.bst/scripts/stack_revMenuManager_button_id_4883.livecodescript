script "stack_revMenuManager_button_id_4883"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > group "Menu Button Controls" (id 4879) > button "Disable Menu" (id 4883)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVActiveMenuButton
  lock screen
  revCheckNameChanged
  set the backPattern of me to empty
  if the hilite of me then
    disable gREVActiveMenuButton
  else
    enable gREVActiveMenuButton
  end if
  unlock screen
end mouseUp
