script "stack_revMenuManager_button_id_4884"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > group "Menu Button Controls" (id 4879) > button "Menu Mnemonic" (id 4884)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVActiveMenuButton
  revCheckNameChanged
  put the hilitedLine of fld "Menu Buttons" into tHilitedLine
  lock screen
  set the hilitedLine of fld "Menu Buttons" to 0 --workaround bug #2878
  if the hilite of me then
    --enable mnemonic
    enable btn "Menu Mnemonic Letter"
    if the label of btn "Menu Mnemonic Letter" is not space then
      --remember mnemonic if it has been set since a menu has been selected
      put offset(the label of btn "Menu Mnemonic Letter", the label of gREVActiveMenuButton) into tMnemonic
      set the mnemonic of gREVActiveMenuButton to tMnemonic
      set the textStyle of line tHilitedLine of fld "Menu Buttons" to "plain"
      set the textStyle of char tMnemonic of line tHilitedLine of fld "Menu Buttons" to "underline"
    end if
  else
    set the mnemonic of gREVActiveMenuButton to 0
    set the textStyle of line tHilitedLine of fld "Menu Buttons" to "plain"
    disable btn "Menu Mnemonic Letter"
  end if
  set the hilitedLine of fld "Menu Buttons" to tHilitedLine --workaround bug #2878
  unlock screen
end mouseUp
