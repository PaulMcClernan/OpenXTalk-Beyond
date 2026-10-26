script "stack_revMenuManager_button_id_4880"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > group "Menu Button Controls" (id 4879) > button "Menu Mnemonic Letter" (id 4880)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  global gREVActiveMenuButton
  revCheckNameChanged
  --option menu with all letters in the name of the menu button as options to set mnemonic
  put the label of gREVActiveMenuButton into tName
  put the mnemonic of gREVActiveMenuButton into tMnemonic
  put empty into tMnemonics
  repeat for each char c in tName
    put c & cr after tMnemonics
  end repeat
  delete last char of tMnemonics
  put tMnemonics into me
  set the menuHistory of me to tMnemonic
end mouseDown
  
on menuPick pWhich
  global gREVActiveMenuButton
  lock screen
  hilite btn "Menu Mnemonic"
  put the hilitedLine of fld "Menu Buttons" into tHilitedLine
  put word 2 of the selectedLine of me into tMnemonic
  set the mnemonic of gREVActiveMenuButton to tMnemonic
  set the hilitedLine of fld "Menu Buttons" to 0 --workaround bug #2878
  set the textStyle of line tHilitedLine of fld "Menu Buttons" to "plain"
  set the textStyle of char tMnemonic of line tHilitedLine of fld "Menu Buttons" to "underline"
  set the hilitedLine of fld "Menu Buttons" to tHilitedLine --workaround bug #2878
  unlock screen
  pass menuPick
end menuPick
