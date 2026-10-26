script "stack_revMenuManager_button_id_4852"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Items:" (id 3226) > button "Item Style" (id 4852)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  revCheckNameChanged
  pass mouseDown
end mouseDown

on menuPick pWhich
   global gREVActiveMenuButton, gREVMMMenuItems
   local tHilitedLine, tScroll, tText, tUnicode, tTab, tBracket, tCheck, tDiamond, tAdd, tMenuItem
   lock screen
   put the hilitedLine of fld "Menu Items" into tHilitedLine
   put the vScroll of fld "Menu Items" into tScroll
   put the text of gREVActiveMenuButton into tText
   
   if comma is in the effective textFont of gREVActiveMenuButton then
      put true into tUnicode
      --put uniEncode(tab) into tTab  --TL 12/22, don't delete tab or bracket
      --put uniEncode("(") into tBracket
      put uniEncode("!c") into tCheck
      put uniEncode("!r") into tDiamond
      put "3" into tAdd
   else
      put false into tUnicode
      --put tab into tTab
      --put "(" into tBracket
      put "!c" into tCheck
      put "!r" into tDiamond
      put "1" into tAdd
   end if
   
   switch pWhich
      case "None"  --no checkmark, no diamond
         put item 2 of line tHilitedLine of gREVMMMenuItems into tMenuItem
         --replace tTab with empty in tMenuItem
         --replace tBracket with empty in tMenuItem
         if char 1 of tMenuItem = "!" then
            delete char 1 to (1 + tAdd) of tMenuItem
            put tMenuItem into item 2 of line tHilitedLine of gREVMMMenuItems
            put revUniUpdateLine(tMenuItem, item 3 of line tHilitedLine of gREVMMMenuItems, tText, tUnicode) into tText
         end if  --TL 12/22, include tUnicode param in function to fix null chars added to non-unicode text
         break
      case "Checked"  --checkmark
         put item 2 of line tHilitedLine of gREVMMMenuItems into tMenuItem
         --replace tTab with empty in tMenuItem
         --replace tBracket with empty in tMenuItem
         if char 1 to (1 + tAdd) of tMenuItem = tCheck then exit menuPick  --already checkmark
         else if char 1 to (1 + tAdd) of tMenuItem = tDiamond then  --replace diamond
            put tCheck into char 1 to (1 + tAdd) of tMenuItem
            put tMenuItem into item 2 of line tHilitedLine of gREVMMMenuItems
            put revUniUpdateLine(tMenuItem, item 3 of line tHilitedLine of gREVMMMenuItems, tText, tUnicode) into tText
         else  --add checkmark
            put tCheck before tMenuItem
            put tMenuItem into item 2 of line tHilitedLine of gREVMMMenuItems
            put revUniUpdateLine(tMenuItem, item 3 of line tHilitedLine of gREVMMMenuItems, tText, tUnicode) into tText
         end if
         break
      case "Diamond"  --diamond
         put item 2 of line tHilitedLine of gREVMMMenuItems into tMenuItem
         --replace tTab with empty in tMenuItem
         --replace tBracket with empty in tMenuItem
         if char 1 to (1 + tAdd) of tMenuItem = tDiamond then exit menuPick  --already diamond
         else if char 1 to (1 + tAdd) of tMenuItem = tCheck then  --replace checkmark
            put tDiamond into char 1 to (1 + tAdd) of tMenuItem
            put tMenuItem into item 2 of line tHilitedLine of gREVMMMenuItems
            put revUniUpdateLine(tMenuItem, item 3 of line tHilitedLine of gREVMMMenuItems, tText, tUnicode) into tText
         else  --add diamond
            put tDiamond before tMenuItem
            put tMenuItem into item 2 of line tHilitedLine of gREVMMMenuItems
            put revUniUpdateLine(tMenuItem, item 3 of line tHilitedLine of gREVMMMenuItems, tText, tUnicode) into tText
         end if
         break
   end switch
   
   set the text of gREVActiveMenuButton to tText  --update button contents
   put tText into btn "Preview"     
   revUpdateField tUnicode
   set the hilitedLine of fld "Menu Items" to tHilitedLine
   set the vScroll of fld "Menu Items" to tScroll
   send "mouseUp" to fld "Menu Items" in 10 milliseconds
   unlock screen
end menuPick
