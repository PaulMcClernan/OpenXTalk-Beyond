script "stack_revMenuManager_field_id_4847"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Items:" (id 3226) > field "Item Name" (id 4847)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
   revChangeMenuItemName
end closeField

on revChangeMenuItemName
   global gREVMMMenuItems, gREVActiveMenuButton
   if the cAnswerDialog of me or the disabled of me then exit revChangeMenuItemName
   
   put true into tUnicode
   
   put the hilitedLine of fld "Menu Items" into tHilitedLine
   
   put the unicodeText of me into tNewItemName
   put uniDecode(tNewItemName,"UTF8") into tNewItemName
   
   if tUnicode then      
      put tab into tTab
      put "(" into tBracket
      put "!c" into tCheck
      put "!r" into tRadio
      put "-" into tHyphen
      put "&" into tAnphasand
   else 
      
      put item 3 of line tHilitedLine of gREVMMMenuItems into tMenuLine
      set the cAnswerDialog of me to true
      if tMenuLine is the num of lines in the text of gREVActiveMenuButton - 1 and the text of me is not "-" then
         switch
            case the hilitedLine of fld "Menu Buttons" is 1
               set the cBroughtUpAnswerDialog of me to true
               answer warning "As the Quit menu item is moved to the Application menu on Mac OS X, this menu item must be a divider, and removes it on Mac OS X." with "OK" titled "Menu Builder"
               break
            case line (the hilitedLine of fld "Menu Buttons") of fld "Menu Buttons" is "Edit"
               set the cBroughtUpAnswerDialog of me to true
               answer warning "As the Preferences menu item is moved to the Application menu on Mac OS X, this menu item must be a divider, and removes it on Mac OS X." with "OK" titled "Menu Builder"
               break
            case the hilitedLine of fld "Menu Buttons" is the num of lines in fld "Menu Buttons"
               set the cBroughtUpAnswerDialog of me to true
               answer warning "As the About menu item is moved to a different menu on Mac OS, this menu item must be a divider, and removes it on Mac OS." with "OK" titled "Menu Builder"
               break
         end switch
         lock messages
         put "-" into me
         unlock messages
      end if
   else if tMenuLine is the num of lines in the text of gREVActiveMenuButton \
         and line (the hilitedLine of fld "Menu Buttons") of fld "Menu Buttons" is "Edit" \
         and the text of me is not among the items of "Preferences,Preferences..." then
      set the cBroughtUpAnswerDialog of me to true
      answer warning "The Preferences menu item is moved to the Application menu on Mac OS X and so must appear as Preferences... on this platform." with "OK" titled "Menu Builder"
      lock messages
      put "Preferences" into me
      unlock messages
   end if
   set the cAnswerDialog of me to false
   
   put the text of me into tNewItemName
   put tab into tTab
   put "(" into tBracket
   put "!c" into tCheck
   put "!r" into tRadio
   put "-" into tHyphen
   put "&" into tAnphasand
end if

put the cREVCommandKeyShortcut of fld "Item Name" into tCommandKeyShortcut
put the cRevTag of fld "Item Name" into tTag

put the cREVTabCount of fld "Item Name" into tTabCount
put the scroll of fld "Menu Items" into tScroll
put item 3 of line tHilitedLine of gREVMMMenuItems into tMenuLine

if tUnicode then
   put the unicodeText of gREVActiveMenuButton into tText
else
   put the text of gREVActiveMenuButton into tText
end if

if the label of btn "Item Style" is "Checked" 
then put tCheck before tNewItemName
else if the label of btn "Item Style" is "Diamond" 
then put tRadio before tNewItemName
if tNewItemName is not tHyphen and the hilite of btn "Item Disable" 
then put tBracket before tNewItemName

repeat tTabCount
   put tTab before tNewItemName      
end repeat

put offset(the cREVMnemonic of fld "Item Name", tNewItemName) into tOffset
if tOffset is not 0 then put tAnphasand before char tOffset of tNewItemName

if tCommandKeyShortcut is not empty then put tCommandKeyShortcut after tNewItemName
// SN-2014-11-26: [[ Bug 14072 ]] Update the menu manager to display the tags of menu items
if tTag is not empty then put tTag after tNewItemName
put revUniUpdateLine(tNewItemName, tMenuLine, tText, tUnicode) into tText
replace comma with "#####REVCOMMA#####" in tNewItemName

put tNewItemName into item 2 of line tHilitedLine of gREVMMMenuItems

if tUnicode then
   set the unicodetext of gREVActiveMenuButton to tText
else
   set the text of gREVActiveMenuButton to tText
end if

lock screen

if tUnicode then
   set the unicodeText of button "preview" to tText
else
   put tText into btn "Preview"
end if

revUpdateField tUnicode
set the hilitedLines of fld "Menu Items" to tHilitedLine
set the scroll of fld "Menu Items" to tScroll

unlock screen
if not the cREVClosing of this stack
then send "mouseUp" to fld "Menu Items" in 10 milliseconds
end revChangeMenuItemName

on returnInField
  revChangeMenuItemName
  send "revSelectRenameText" to me in 50 milliseconds
end returnInField

on revSelectRenameText
  select the text of me
end revSelectRenameText

on enterInField
  returnInField
end enterInField
