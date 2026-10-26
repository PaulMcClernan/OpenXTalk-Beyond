script "stack_revMenuManager_button_id_8002"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Item Controls" (id 3265) > button "Item Tagged" (id 8002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gREVActiveMenuButton, gREVMMMenuItems
   lock screen
   put the hilite of me into tOldHilite
   if the name of the focusedObject contains "Item Name" then focus field "Item tag"  --SN-2015-01-06: [[ Bug 14155 ]] change focus
   put the hilitedLine of fld "Menu Items" into tHilitedLine
   put item 3 of line tHilitedLine of gREVMMMenuItems into tMenuLine
   put the vScroll of fld "Menu Items" into tScroll
   put false into tUnicode  --TL 12/22, changed from true to false
   put the unicodetext of gREVActiveMenuButton into tMenuItemText
   put item 2 of line tHilitedLine of gREVMMMenuItems into tMenuItemPlainText  --SN-2015-01-07: [[ Bug 14341 ]] avoid adding shortcuts in gREVMMMenuItems
   put unidecode(tMenuItemText, "UTF8") into tMenuItemText
   put line tMenuLine of tMenuItemText into tMenuItemNewText
   
   if tUnicode then put the unicodetext of gREVActiveMenuButton into tText
   else put the text of gREVActiveMenuButton into tText
   
   put offset("|", tMenuItemNewText) into tOffset  --SN-2015-01-07: [[ Bug 14341 ]] tag delimiter is "|", not "/|"
   if tOffset is not "0" then
      delete char tOffset to -1 of tMenuItemNewText
      --SN-2015-01-07: [[ Bug 14341 ]] delete slash if menu item has no shortcut
      if char -1 of tMenuItemNewText is "/" then delete char -1 of tMenuItemNewText
   end if
   
   put offset("|", tMenuItemPlainText) into tOffset  --SN-2015-01-07; [[ Bug 14341 ]] update plain text
   if tOffset is not "0" then
      delete char tOffset to -1 of tMenuItemPlainText
      if char -1 of tMenuItemPlainText is "/" then delete char -1 of tMenuItemPlainText
   end if
   
   put empty into tNewTag
   if the hilite of me then  --set current tag to the item
      enable field "Item Tag"
      if field "Item Tag" is not empty then  --no unicode for tags
         --SN-2015-01-07: [[ Bug 14341 ]] tag delimiter is "/", not "/|", but a slash is needed before it
         if not (tMenuItemNewText contains "/") then put "/" after tNewTag
         put "|" & the text of field "Item Tag" after tNewTag
      else select the text of fld "Item Tag"  --TL 12/22, insert cursor
      put tNewTag after tMenuItemPlainText
      put tNewTag after tMenuItemNewText
   else  --remove tag
      put empty into fld "Item Tag"  --TL 12/22, remove tag
      disable field "Item Tag"
   end if
   
   --update button contents
   put revUniUpdateLine(tMenuItemNewText, tMenuLine, tText, tUnicode) into tText
   put tMenuItemPlainText into item 2 of line tHilitedLine of gREVMMMenuItems
   
   if tUnicode then
      set the unicodetext of gREVActiveMenuButton to tText
      put unidecode(tText, "UTF8") into btn "Preview"
   else
      set the text of gREVActiveMenuButton to tText
      put tText into btn "Preview"    
   end if
   
   revUpdateField tUnicode
   set the hilitedLine of fld "Menu Items" to tHilitedLine
   set the vScroll of fld "Menu Items" to tScroll
   unlock screen
end mouseUp
