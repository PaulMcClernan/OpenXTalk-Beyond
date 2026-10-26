script "stack_revMenuManager_field_id_4864"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Item Controls" (id 3265) > field "Shortcut" (id 4864)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on KeyDown  --only allow entry of one character
  if the selectedText of me is empty and the num of chars in me > "0" then
    beep
    exit KeyDown
  end if
  pass KeyDown
end KeyDown

on keyUp pKey
  global gREVActiveMenuButton, gREVMMMenuItems
  put the hilitedLine of fld "Menu Items" into tHilitedLine
  put item 3 of line tHilitedLine of gREVMMMenuItems into tMenuLine
  --check if shortcut already exists
  put the cREVMenuButtonIds of this stack into tMenuButtonIDs
  put the cREVMenuID of this stack into tMenuID
  set the defaultStack to the cREVDefaultStack of this stack
  
  put empty into tAllMenuItems
  repeat for each line l in tMenuButtonIDs  --compile list of all menu items
    put the text of btn id l of bg id tMenuID & cr after tAllMenuItems
  end repeat
  set the wholeMatches to true
  delete line lineOffset(tMenuLine, tAllMenuItems) of tAllMenuItems
  delete last char of tAllMenuItems
  
  put empty into tShortCutList
  repeat for each line l in tAllMenuItems  --extract all shortcuts
    if char -2 of l is "/" and char -1 of l is not in " /"
    then put char -1 of l & cr after tShortCutList
  end repeat
  delete last char of tShortCutList
  
  if pKey is among the lines of tShortCutList then
    beep
    answer warning "Sorry, this shortcut has already been allocated for another menu item." with "OK" titled "Menu Builder"
    select the text of me
    pass keyUp
  end if
  set the defaultStack to "revMenuManager"
  revSetShortCut  
  pass keyUp
end keyUp
  
on revSetShortCut  --keyboard shortcut
   global gREVActiveMenuButton, gREVMMMenuItems
   lock screen
   put the hilitedLine of fld "Menu Items" into tHilitedLine
   put item 3 of line tHilitedLine of gREVMMMenuItems into tMenuLine
   put item 2 of line tHilitedLine of gREVMMMenuItems into tMenuItem
   put the vScroll of fld "Menu Items" into tScroll
   put the text of gREVActiveMenuButton into tText
   
   put item 2 of line tHilitedLine of gREVMMMenuItems into tMenuItem
   if "/" is char - 2 of tMenuItem and char - 1 of tMenuItem is not "/" and \
         char - 3 of tMenuItem is not "/" then delete char - 2 to -1 of tMenuItem
   if char -1 of tMenuItem is "/" then delete char -1 of tMenuItem
   if char 1 of me is not space and char 1 of me is not empty then put "/" & char 1 of me after tMenuItem
   
   --update button contents
   put tMenuItem into line tMenuLine of tText
   replace comma with "#####REVCOMMA#####" in tMenuItem
   put tMenuItem into item 2 of line tHilitedLine of gREVMMMenuItems
   set the text of gREVActiveMenuButton to tText
   put tText into btn "Preview"     
   revUpdateField
   set the hilitedLines of fld "Menu Items" to tHilitedLine
   set the vScroll of fld "Menu Items" to tScroll
   --if the text of me is empty then unhilite btn "Shortcut Checkbox"  --TL 12/22, created unhilite/hilite loop
   --else hilite btn "Shortcut Checkbox"  --TL 12/22, btn already hilited
   updateMenuLine
   unlock screen
end revSetShortCut

on returnInField
  lock screen
  closeField
  select the text of me
  unlock screen
end returnInField

on enterInField
  returnInField
end enterInField

on closeField
   if the text of me is empty then
      set the hilite of button "Shortcut Checkbox" to false
      set the hilite of button "Command" to false
      set the hilite of button "Control" to false
      set the hilite of button "Option_Alt" to false
      set the hilite of button "Shift" to false
      disable button "Command"
      disable button "Control"
      disable button "Option_Alt"
      disable button "Shift"
   end if
   pass closeField
end closeField

on exitField
   if the text of me is empty then
      set the hilite of button "Shortcut Checkbox" to false
      set the hilite of button "Command" to false
      set the hilite of button "Control" to false
      set the hilite of button "Option_Alt" to false
      set the hilite of button "Shift" to false
      disable button "Command"
      disable button "Control"
      disable button "Option_Alt"
      disable button "Shift"
   end if
end exitField
