script "stack_revMenuManager_button_id_4857"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menubar" (id 3260) > button "New Main Menu" (id 4857)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the cAnswerDialog of field "Menu Name" or the cAnswerDialog of field "Item Name" then exit mouseUp
   revCheckNameChanged
   
   modal "revNewMenu"
   if the cREVResult of stack "revNewMenu" is not "OK" then pass mouseUp
   lock screen
   local tMenubar
   put the cREVMenubar of this stack into tMenubar
   put tMenubar into field "Menubar"
   
   local tDefaultStack
   put the cREVDefaultstack of this stack into tDefaultStack
   set the title of this stack to "Menu Builder:" && tMenubar && "(" & "Stack:" && quote & tDefaultStack & quote & ")"    
   set the defaultStack to tDefaultStack
   
   --properties for menu bar buttons
   set the lockLoc of the templateButton to true
   set the showBorder of the templateButton to false
   --set some properties to make the button behave as a menu
   set the style of the templateButton to "menu"
   set the menuMode of the templateButton to "pulldown"
   set the opaque of the templateButton to true
   set the autoHilite of the templateButton to true
   set the hiliteBorder of the templateButton to true
   set the armBorder of the templateButton to true
   set the traversalOn of the templateButton to false
   set the showBorder of the templateButton to false   
   
   lock messages--avoids resetting templateButton after creating a btn
   --create menu bar group
   if the hilite of button "Move objects" of cd 1 of stack "revNewMenu" then
      repeat with x = 1 to the number of cards
         local tNumControls
         put the num of controls in cd x into tNumControls
         repeat with i = 1 to tNumControls
            if word 1 of the owner of control i of cd x is not "group"
            then set the top of control i of cd x to the top of control i of cd x + 22
         end repeat
      end repeat
      set the rect of this stack to item 1 to 3 of the rect of this stack, \
            the bottom of this stack + 22
      modeless "revMenuManager"--workaround engine bug where resized stack brought to front
   end if
   
   set the name of the templateGroup to tMenubar
   set the traversalOn of the templateGroup to false
   set the backgroundBehavior of the templateGroup to true
   create group
   local tMenuID
   put the id of it into tMenuID
   reset the templateGroup
   repeat with i = 1 to the number of cards in this stack
      if tMenuID is not among the lines of the groupIDs of cd i then
         place group id tMenuID onto card i
      end if
   end repeat
   
   local tNextLeft
   put 1 into tNextLeft
   
   local tMenuButtonIds
   put empty into tMenuButtonIds
   
   local tField
   put the long id of field "Menus" of cd 1 of stack "revNewMenu" into tField 
   
   local tMenusToBuild
   put the text of tField into tMenusToBuild
   
   local tMenuName
   put revNewMenuName(the long id of bg id tMenuID,1) into tMenuName
   
   local tMenuNum
   put word 2 of tMenuName into tMenuNum
   
   local tCount
   put 0 into tCount
   lock screen
   repeat for each line tMenuButtonName in tMenusToBuild
      add 1 to tCount
      
      local tUnicode
      put false into tUnicode
      
      local tNumChars
      put the num of chars in line tCount of field "Menus" of cd 1 of stack "revNewMenu" into tNumChars
      repeat with i = 1 to tNumChars
         if comma is in the effective textFont of char i of line tCount of field "Menus" of cd 1 of stack "revNewMenu" then
            
            local tTextFont
            put the effective textFont of char i of line tCount of field "Menus" of cd 1 of stack "revNewMenu" into tTextFont
            put true into tUnicode
            exit repeat
         end if
      end repeat
      
      if tUnicode then
         local tName
         put "Menu" && tMenuNum into tName
         add 1 to tMenuNum
         create button tName in group id tMenuID
         set the textFont of it to tTextFont
         set the label of it to the unicodeText of line tCount of tField
         set the text of it to uniEncode("Item 1")
      else
         create button l in group id tMenuID
         set the label of it to tMenuButtonName
         -----------------------------------
         -- LG-2008-01-29  Bug 5788
         set the name of it to tMenuButtonName
         ------------------------------------
         if tMenuButtonName is not among the items of "File,Edit,Help" then
            # OK-2007-09-23 : Unquoted literal in use here, corrected.
            -- set the text of button id tButtonID of group id tMenuID to "Item 1"
            set the text it to "Item 1"
         end if
      end if
      
      local tButtonId
      put the id of it into tButtonID
      set the rect of button id tButtonID of group id tMenuID to tNextLeft, -1, tNextLeft + the formattedWidth of button id tButtonID of group id tMenuID + 4, -1 + the formattedHeight of button id tButtonID of group id tMenuID -2
      add the width of button id tButtonID of group id tMenuID to tNextLeft
      put tButtonID & cr after tMenuButtonIds
   end repeat
   delete last char of tMenuButtonIds
   reset the templateButton
   
   unlock screen
   unlock messages
   
   --changing context
   lock screen
   set the defaultStack to "revMenuManager"
   set the cREVMenuID of this stack to tMenuID
   set the cREVMenuButtonIds of this stack to tMenuButtonIds
   set the wholeMatches to true
   --Menu Buttons field
   set the wholeMatches to true
   set the htmlText of field "Menu Buttons" to the htmlText of field "Menus" of cd 1 of stack "revNewMenu"
   if "File" is among the lines of tMenusToBuild then
      --preset File Menu attributes
      
      local tLineOffset
      put lineOffset("File", tMenusToBuild) into tLineOffset
      put line tLineOffset of tMenuButtonIds into tMenuID
      set the text of button id tMenuID of bg tMenubar of stack tDefaultStack to "&New"&cr&"&Open/O"&cr&"&Close/W"&cr&"-"&cr&"&Quit/Q"
      set the mnemonic of button id tMenuID of bg tMenubar of stack tDefaultStack to 1
      set the textStyle of char 1 of line tLineOffset of field "Menu Buttons" to "underline"
   end if
   if "Edit" is among the lines of tMenusToBuild then
      --preset Edit Menu attributes
      put lineOffset("Edit", tMenusToBuild) into tLineOffset
      put line tLineOffset of tMenuButtonIds into tMenuID
      set the text of button id tMenuID of bg tMenubar of stack tDefaultStack to "Cu&t/X" &cr& "&Copy/C" &cr& "&Paste/V" &cr& "Clea&r"&cr&"-"&cr&"Preferences"
      set the mnemonic of button id tMenuID of bg tMenubar of stack tDefaultStack to 1
      set the textStyle of char 1 of line tLineOffset of field "Menu Buttons" to "underline"
   end if
   if "Help" is among the lines of tMenusToBuild then
      --preset Help Menu attributes
      put lineOffset("Help", tMenusToBuild) into tLineOffset
      put line tLineOffset of tMenuButtonIds into tMenuID
      set the text of button id tMenuID of bg tMenubar of stack tDefaultStack to "&Help" & cr & "-" & cr & "&About"
      set the mnemonic of button id tMenuID of bg tMenubar of stack tDefaultStack to 1
      set the textStyle of char 1 of line tLineOffset of field "Menu Buttons" to "underline"
   end if
   
   -- OXT-Beyond: the IDE's handler is revIDESetEdited (TerryL turned this
   -- off in 12/23: "there is no revSetEdited custom cmd")
   revIDESetEdited tDefaultStack
   revInitialiseForNewMenu
   send "mouseUp" to field "Menu Buttons"
   revInitialiseForNoItemSelection
   
   # OK-2009-04-03: Bug 7793 - This should be hilited by default, otherwise
   # the group won't be sent mousedown
   --unhilite button "MacOS Menu Bar"
   hilite button "MacOS Menu Bar"
   send "mouseUp" to button "MacOS Menu Bar"
   select the text of field "Menubar"
   unlock screen
end mouseUp
