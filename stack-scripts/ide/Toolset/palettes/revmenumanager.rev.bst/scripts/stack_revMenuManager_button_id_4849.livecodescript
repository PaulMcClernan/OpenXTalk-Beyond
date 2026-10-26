script "stack_revMenuManager_button_id_4849"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Items:" (id 3226) > button "Move Item Up" (id 4849)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gREVActiveMenuButton, gREVMMMenuItems
   lock screen
   revCheckNameChanged
   
   --if comma is in the effective textFont of gREVActiveMenuButton then
   put true into tUnicode
   --put uniEncode(cr) into tCr
   --else
   --put false into tUnicode
   put cr into tCr
   --end if
   
   --move selected menu item down one in the list
   put the hilitedLine of fld "Menu Items" into tHilitedLine
   put the scroll of fld "Menu Items" into tScroll
   --put the text of gREVActiveMenuButton into tText
   put the unicodetext of gREVActiveMenuButton into tText
   put uniDecode(tText,"UTF8") into tText
   
   replace tCr with cr in tText
   put gREVMMMenuItems into tMenuItems
   
   put tHilitedLine + 1 into tNextLine
   put tHilitedLine + 2 into tNextAgainLine
   put tHilitedLine - 1 into tPrevLine
   put line tHilitedLine of tMenuItems into tCurrentMenuItem
   put line tNextLine of tMenuItems into tNextMenuItem
   put line tNextAgainLine of tMenuItems into tNextAgainMenuItem
   put line tPrevLine of tMenuItems into tPrevMenuItem  
   put item 3 of tCurrentMenuItem into tCurrentRef
   put item 3 of tNextMenuItem into tNextRef
   put item 3 of tNextAgainMenuItem into tNextAgainRef
   put item 3 of tPrevMenuItem into tPrevRef     
   put item 1 of tCurrentMenuItem into tCurrentTriangle
   put item 1 of tNextMenuItem into tNextTriangle
   put item 1 of tNextAgainMenuItem into tNextAgainTriangle
   put item 1 of tPrevMenuItem into tPrevTriangle
   
   --------------------change button text--------------------------
   switch
      case tCurrentTriangle is empty and tPrevTriangle is empty
         --both standard menu items
         put item 2 of tPrevMenuItem into line tCurrentRef of tText
         put item 2 of tCurrentMenuItem into line tPrevRef of tText
         
         --change variable reference
         put line tHilitedLine of tMenuItems & cr before line (tHilitedLine-1) of tMenuItems
         delete line (tHilitedLine+1) of tMenuItems    
         put tPrevRef into item 3 of line tPrevLine of tMenuItems
         put tCurrentRef into item 3 of line tHilitedLine of tMenuItems
         break
      case tCurrentTriangle is empty and tPrevTriangle is false
         --selected menu item standard, previous one folded in triangle
         put line tCurrentRef of tText & cr before line tPrevRef of tText
         delete line (tCurrentRef+1) of tText
         
         
         --change variable reference
         put line tHilitedLine of tMenuItems & cr before line (tHilitedLine-1) of tMenuItems
         delete line (tHilitedLine+1) of tMenuItems
         put tPrevRef into item 3 of line tPrevLine of tMenuItems
         put tPrevRef + 1 into item 3 of line tHilitedLine of tMenuItems
         break
      case tCurrentTriangle is false and tPrevTriangle is empty
         --selected menu item folded in triangle, previous one standard   
         put tCurrentRef + 1 into tStartLine
         put the num of lines in tText into tEndLine
         put empty into tStopLine
         repeat with i = tStartLine to tEndLine
            if tab is in line i of tText then next repeat
            else
               put i into tStopLine
               exit repeat
            end if       
         end repeat
         
         if tStopLine is not empty then put tStopLine - 1 into tChunkEnd
         else put tEndline into tChunkEnd
         put tChunkEnd - tCurrentRef into tNumSubMenus
         put line tCurrentRef to tChunkEnd of tText & cr before line tPrevRef of tText
         delete line (tCurrentRef+tNumSubMenus+1) to (tChunkEnd+tNumSubMenus+1) of tText
         --change variable reference    
         put line tHilitedLine of tMenuItems & cr before line (tHilitedLine-1) of tMenuItems
         delete line (tHilitedLine+1) of tMenuItems
         put tPrevRef into item 3 of line tPrevLine of tMenuItems    
         put tPrevRef + 1 + tNumSubMenus into item 3 of line tHilitedLine of tMenuItems    
         break
      case tCurrentTriangle is false and tPrevTriangle is false
         --both folded in
         --selected menu item folded in triangle, previous one standard   
         put tCurrentRef + 1 into tStartLine
         put the num of lines in tText into tEndLine
         put empty into tStopLine
         repeat with i = tStartLine to tEndLine
            if tab is in line i of tText then next repeat
            else
               put i into tStopLine
               exit repeat
            end if       
         end repeat
         
         if tStopLine is not empty then put tStopLine - 1 into tChunkEnd
         else put tEndline into tChunkEnd
         put tChunkEnd - tCurrentRef into tNumSubMenus
         put line tCurrentRef to tChunkEnd of tText & cr before line tPrevRef of tText
         delete line (tCurrentRef+tNumSubMenus+1) to (tChunkEnd+tNumSubMenus+1) of tText
         
         --change variable reference
         put line tHilitedLine of tMenuItems & cr before line (tHilitedLine-1) of tMenuItems
         delete line (tHilitedLine+1) of tMenuItems
         put tPrevRef into item 3 of line tPrevLine of tMenuItems    
         put tPrevRef + 1 + tNumSubMenus into item 3 of line tHilitedLine of tMenuItems
         break  
   end switch
   put tMenuItems into gREVMMMenuItems
   
   --replace cr with tCr in tText
   replace "#####REVCOMMA#####" with comma in tText
   --set the text of gREVActiveMenuButton to tText
   --put tText into btn "Preview"    
   
   set the unicodeText of gREVActiveMenuButton to uniEncode(tText,"UTF8")
   set the unicodeText of button "Preview" to uniEncode(tText,"UTF8") 
   
   revUpdateField tUnicode
   set the hilitedLine of fld "Menu Items" to tHilitedLine - 1
   set the scroll of fld "Menu Items" to tScroll
   revResetTriangles
   send "mouseUp" to fld "Menu Items" in 10 milliseconds
   unlock screen
end mouseUp

setProp cREVDisabled pDisabled
  if pDisabled then
    disable me
  else
    enable me
  end if
end cREVDisabled
