script "stack_revMenuManager_button_id_4854"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Items:" (id 3226) > button "Increase Item Nesting" (id 4854)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   --increase item nesting
   global gREVActiveMenuButton, gREVMMMenuItems
   lock screen
   revCheckNameChanged
   
   --if comma is in the effective textFont of gREVActiveMenuButton then
   put true into tUnicode
   --put uniEncode(tab) into tTab
   --put uniEncode("(") into tBracket
   --else
   --put false into tUnicode
   --put tab into tTab
   --put "(" into tBracket
   --end if
   
   put the hilitedLines of fld "Menu Items" into tHilitedLines
   put the scroll of fld "Menu Items" into tScroll
   
   put the unicodetext of gREVActiveMenuButton into tText
   put uniDecode(tText,"UTF8") into tText
   
   put (item 1 of tHilitedLines) - 1 into tPrevLineNum
   put line (item 1 of tHilitedLines) of fld "Menu Items" into tLine
   put line tPrevLineNum of fld "Menu Items" into tPrevLine
   put 0 into tNumTabs
   repeat for each char c in tLine
      if c is tab then add 1 to tNumTabs
   end repeat
   put 0 into tPrevNumTabs
   repeat for each char c in tPrevLine
      if c is tab then add 1 to tPrevNumTabs
   end repeat
   
   if tNumTabs is 1 and tPrevNumTabs is 1 then 
      put true into item 1 of line tPrevLineNum of gREVMMMenuItems
   end if
   
   repeat for each item i in tHilitedLines
      put item 2 of line i of gREVMMMenuItems into tMenuItem
      --put offset(tCheck, tMenuItem) into tOffset
      if char 1 of tMenuItem = "!" then put tab after char 2 of tMenuItem  --TL 12/22, fix for tab with !c or !r in tMenuItem
      else put tab before tMenuItem
      put tMenuItem into item 2 of line i of gREVMMMenuItems
      put revUniUpdateLine(tMenuItem, item 3 of line i of gREVMMMenuItems, the unicodetext of gREVActiveMenuButton, true) into tText
   end repeat
   
   --update button contents
   replace "#####REVCOMMA#####" with comma in tText
   
   --   set the text of gREVActiveMenuButton to tText
   --   put tText into btn "Preview"     
   set the unicodeText of gREVActiveMenuButton to tText
   set the unicodeText of button "Preview" to tText
   
   revUpdateField tUnicode
   set the hilitedLines of fld "Menu Items" to tHilitedLines
   set the scroll of fld "Menu Items" to tScroll
   --revResetTriangles  --TL 12/22, commented out to remove tree view btns
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
