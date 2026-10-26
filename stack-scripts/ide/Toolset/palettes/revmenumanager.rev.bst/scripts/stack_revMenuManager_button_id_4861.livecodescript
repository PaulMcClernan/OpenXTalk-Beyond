script "stack_revMenuManager_button_id_4861"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Item Controls" (id 3265) > button "Item Disable" (id 4861)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --enable/disable selected menu item
   global gREVActiveMenuButton, gREVMMMenuItems
   local tHilitedLine, tScroll, tText, tMenuItem, tFilteredMenuItem, tAlreadyDisabled, tLine, tUnicode
   lock screen
   revCheckNameChanged
   set the backPattern of me to empty
   
   put the hilitedLine of fld "Menu Items" into tHilitedLine
   put the vScroll of fld "Menu Items" into tScroll
   put the text of gREVActiveMenuButton into tText
   
   put item 2 of line tHilitedLine of gREVMMMenuItems into tMenuItem
   put tMenuItem into tFilteredMenuItem
   replace "!c" with empty in tFilteredMenuItem
   replace "!r" with empty in tFilteredMenuItem
   replace tab with empty in tFilteredMenuItem
   if char 1 of tFilteredMenuItem is in "(-" then put true into tAlreadyDisabled
   else put false into tAlreadyDisabled
   
   if the hilite of me then  --disable menuItem with "("
      switch
         case tAlreadyDisabled
            break
         case tab is in tMenuItem
            put "(" after char offset(tab, tMenuItem) of tMenuItem  --"(" after tab
            break
         case "!" = char 1 of tMenuItem
            put "(" after char 2 of tMenuItem  --"(" after !c or !r
            break
         default
            put "(" before tMenuItem  --"("
            break          
      end switch
   else  --enable menuItem
      if tAlreadyDisabled then delete char offset("(",tMenuItem) of tMenuItem
   end if
   
   put tMenuItem into item 2 of line tHilitedLine of gREVMMMenuItems
   put item 3 of line tHilitedLine of gREVMMMenuItems into tLine
   put revUniUpdateLine(tMenuItem,tLine,tText, tUnicode) into tText  --TL 12/22, add tUnicode param
   
   --update button contents
   set the text of gREVActiveMenuButton to tText
   put tText into btn "Preview"
   revUpdateField false
   set the hilitedLine of fld "Menu Items" to tHilitedLine
   set the vScroll of fld "Menu Items" to tScroll
   unlock screen
end mouseUp
