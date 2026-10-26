script "stack_revMenuManager_button_id_4862"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Item Controls" (id 3265) > button "Item Mnemonic Letter" (id 4862)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
   global gREVActiveMenuButton, gREVMMMenuItems
   lock screen
   revCheckNameChanged  
   
   --option menu with all letters in the name of the menu item as options to set mnemonic
   put item 2 of line (the hilitedLine of fld "Menu Items") of gREVMMMenuItems into tMenuItem
   replace tab with empty in tMenuItem
   if char 1 of tMenuitem is "(" then delete char 1 of tMenuItem
   repeat for each item i in "!c,!n,!r,!u"
      if char 1 to 2 of tMenuItem is i then
         delete char 1 to 2 of tMenuItem
         exit repeat
      end if
   end repeat
   
   -- SN-2015-01-07: [[ Bug 14341 ]] The shortcut can be before the last chars
   put offset("/", tMenuItem) into tSlashOffset
   put offset("|", tMenuItem, tSlashOffset) + tSlashOffset into tPipeOffset
   
   if tPipeOffset is not tSlashOffset then
      put tPipeOffset into tShortcutEnd
   else
      -- the last char is length + 1 - 1
      put the number of chars in tMenuItem + 1 into tShortcutEnd
   end if
   
   -- SN-2015-01-07: [[ Bug 14341 ]] If the characters before the tag (if any) are a shortcut,
   --   then we remove everything from that point
   if char tShortcutEnd -2 of tMenuItem is "/" and char tShortcutEnd - 3 of tMenuItem is not "/" and char tShortcutEnd - 1 of tMenuItem is not "/" then 
      delete char tShortcutEnd -2 to -1 of tMenuItem
   else if tSlashOffset is tPipeOffset - 1 then
      delete char tSlashOffset to -1 of tMenuItem
   end if
   put offset("&", tMenuItem) into tOffset
   delete char tOffset of tMenuitem
   put empty into tMnemonics
   repeat for each char c in tMenuItem
      put c & cr after tMnemonics
   end repeat
   delete last char of tMnemonics
   put empty into me
   put tMnemonics into me
   set the menuHistory of me to tOffset
   unlock screen
   pass mouseDown
end mouseDown

on menuPick pWhich
  global gREVActiveMenuButton, gREVMMMenuItems
  
  hilite btn "Item Mnemonic"
  put the hilitedLine of fld "Menu Items" into tHilitedLine
  put item 3 of line tHilitedLine of gREVMMMenuItems into tMenuLine
  put the scroll of fld "Menu Items" into tScroll
  put the text of gREVActiveMenuButton into tText
   
  put item 2 of line tHilitedLine of gREVMMMenuItems into tMenuItem
  put offset("&", tMenuItem) into tOffset
  if tOffset is not 0 and char (tOffset+1) of tMenuItem is not "&" 
  then delete char tOffset of tMenuItem
  
  
  put word 2 of the selectedLine of me into tNewOffset
  #correct offset for special characters
  repeat for each item i in "!c,!r,!u,!n"
    if i is in tMenuItem then
      add 2 to tNewOffset
      exit repeat
    end if
  end repeat
  if "(" is in tMenuItem then add 1 to tNewOffset
  put 0 into tSkip
  repeat
    put offset(tab,tMenuItem,tSkip) into tOffset
    if tOffset is 0 then exit repeat
    add 1 to tNewOffset
    add tOffset to tSkip    
  end repeat
  put "&" before char tNewOffset of tMenuItem
  
  --update button contents
  put tMenuItem into line tMenuLine of tText
  put tMenuItem into item 2 of line tHilitedLine of gREVMMMenuItems
  set the text of gREVActiveMenuButton to tText
  put tText into btn "Preview"
  revUpdateField
  set the hilitedLines of fld "Menu Items" to tHilitedLine
  set the scroll of fld "Menu Items" to tScroll
  pass menuPick
end menuPick
