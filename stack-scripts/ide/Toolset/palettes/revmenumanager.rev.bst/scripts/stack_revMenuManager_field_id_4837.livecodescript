script "stack_revMenuManager_field_id_4837"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Items:" (id 3226) > field "Menu Items" (id 4837)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
   if the text of me is empty or the mouseLine is empty then exit mouseDown
   --put revMenuItemHilitedLines() into tHilitedLines  --TL 12/22, fix to remove multipleHilites
   set the cBroughtUpAnswerDialog of fld "Item Name" to false
   revCheckNameChanged
   lock screen
   --set the hilitedLines of me to tHilitedLines  --TL 12/22, fix to remove multipleHilites
   set the hilitedLine of me to (word 2 of the mouseLine)  --TL 12/22, select line clicked
   mouseUp  --TL 11/22, fix to reposition orange line smoothly
   --if the cBroughtUpAnswerDialog of fld "Item Name" then mouseUp  --TL 12/22, unnecessary
   unlock screen
end mouseDown

function revMenuItemHilitedLines
  if the num of words in the text of me is 0 or the mouseLine is empty then return empty
  put word 2 of the mouseLine into tMouseLine
  if the commandKey is down then
    put the hilitedLines of me into tHilitedLines
    if tMouseLine is among the items of tHilitedLines
    then delete item itemOffset(tMouseLine, tHilitedLines) of tHilitedLines
    else
      if tHilitedLines is empty
      then put tMouseLine into tHilitedLines
      else put comma&tMouseLine after tHilitedLines
    end if
    return tHilitedLines
  else return tMouseLine
end revMenuItemHilitedLines
 
on mouseUp
   if the cAnswerDialog of fld "Menu Name" or the cAnswerDialog of fld "Item Name" then exit mouseUp
   
   
   lock screen  
   revSetEnabled
   if the text of me is not empty then
      revSetWidgetPosition
      revSetHilite
   end if
   
   if the num of items in the hilitedLines of me is 1
   then revFilterItemName
   
   -- LG 2008-08-29
   -- Need to put the item name into the item name field
   
   local tMenuLine, tSlashOffset, tMenuName
   --put line(the hilitedLine of me) of the unicodeText of me into tMenuLine
   put the unicodeText of line(the hilitedLine of me) of me into tMenuLine
   put uniDecode(tMenuLine,"UTF8") into tMenuLine
   --put offset(slash, tMenuLine) into tSlashOffset
   repeat for each char tChar in tMenuLine
      if tChar is tab then
         next repeat
      else if tChar is slash then
         exit repeat
      end if
      put tChar after tMenuName
   end repeat
   
   if "&" is in tMenuName then replace "&" with "" in tMenuName  --TL 11/2022, fix special chars added to fld "Item Name".
   if "(" is in tMenuName then replace "(" with "" in tMenuName
   if "!c" is in tMenuName then replace "!c" with "" in tMenuName
   if "!r" is in tMenuName then replace "!r" with "" in tMenuName
   --put tMenuName into field "Item Name"
   set the unicodeText of field "Item Name" to uniEncode(tMenuName,"UTF8")
   
   unlock screen
end mouseUp

on mouseRelease
  mouseUp
  pass mouseRelease
end mouseRelease

on revSetHilite
   global gREVActiveMenuButton, gREVMMMenuItems
   if the text of me is empty then exit revSetHilite
   if comma is in the effective textFont of gREVActiveMenuButton then
      put true into tUnicode
      put uniEncode(tab) into tTab
      put uniEncode("(") into tBracket
      put uniEncode("!c") into tCheck
      put uniEncode("!n") into tUncheck
      put uniEncode("!r") into tRadio
      put uniEncode("!u") into tUnRadio
      put uniEncode("-") into tHyphen
      put 2 into t1
      put 4 into t2
      put 6 into t3
   else
      put false into tUnicode
      put tab into tTab
      put "(" into tBracket
      put "!c" into tCheck
      put "!u" into tUnCheck
      put "!r" into tRadio
      put "!u" into tUnRadio
      put "-" into tHyphen
      put 1 into t1
      put 2 into t2
      put 3 into t3
   end if
   
   put the hilitedLines of me into tHilitedLines
   put the text of gREVActiveMenuButton into tText
   --check properties for each menu item for enabling/disabling/mixture updating controls
   put true into tAllSame["Style"]
   put true into tAllSame["Cascade"]
   put true into tAllSame["numtabs"]
   put true into tAllSame["Disable"]
   put true into tAllSame["notfoldouttriangle"]
   
   --save values for the first line then check whether the others match
   put item 1 of tHilitedLines into tFirstLine
   put item 2 of line tFirstLine of gREVMMMenuItems into tItemContents
   
   if item 1 of line tFirstLine of gREVMMMenuItems is not empty
   then put false into tAllSame["notfoldouttriangle"]
   
   put tItemContents into tItemContentsWithoutTabs
   replace tTab with empty in tItemContentsWithoutTabs
   
   switch
      
      --checkbox, hilited
      case char 1 to t2 of tItemContentsWithoutTabs is tCheck
      case char 1 to t3 of tItemContentsWithoutTabs is tBracket & tCheck
         put "Checked" into tValue["style"]
         break
         
         --radio button, hilited
      case char 1 to t2 of tItemContentsWithoutTabs is tRadio
      case char 1 to t3 of tItemContentsWithoutTabs is tBracket & tRadio
         put "Diamond" into tValue["style"]
         break
         
      default
         put "None" into tValue["style"]
         break
   end switch
   
   --is the menu item a submenu
   if tab is in tItemContents then put true into tValue["cascade"]
   else put false into tValue["cascade"]
   --how many levels of tabs does the submenu have
   put empty into tNumTabs
   repeat for each char c in tItemContents
      if c is tab then add 1 to tNumTabs
   end repeat
   put tNumTabs into tValue["numtabs"]
   
   --is the menu item disabled
   if char 1 to t1 of tItemContents is tBracket \
         or char 1 to t2 of tItemContents is tTab & tBracket \
         or tItemContents is tHyphen
   then put true into tValue["disable"]
   else put false into tValue["disable"]
   
   delete item 1 of tHilitedLines
   repeat for each item i in tHilitedLines
      --put line (item 3 of line i of gREVMMMenuItems) of tText into tItemContents
      
      put item 2 of line i of gREVMMMenuItems into tItemContents
      if item 1 of line i of gREVMMMenuItems is not empty
      then put false into tAllSame["notfoldouttriangle"]
      put tItemContents into tItemContentsWithoutTabs
      replace tab with empty in tItemContentsWithoutTabs
      
      
      if tAllSame["Style"] then
         --style of menu ite
         --checkbox, hilited
         switch
            case char 1 to t2 of tItemContentsWithoutTabs is tCheck
            case char 1 to t3 of tItemContentsWithoutTabs is tBracket & tCheck
               put "Checked" into tNewStyle
               put true into tNewHilite
               break
               
               --checkbox, unhilited
            case char 1 to t2 of tItemContentsWithoutTabs is tUnCheck
            case char 1 to t3 of tItemContentsWithoutTabs is tBracket & tUnCheck
               put "Checked" into tNewStyle
               put false into tNewHilite
               break
               
               --radio button, hilited
            case char 1 to t2 of tItemContentsWithoutTabs is tRadio
            case char 1 to t3 of tItemContentsWithoutTabs is tBracket & tRadio
               put "Diamond" into tNewStyle
               put true into tNewHilite
               break
               
               --radio button, unhilited
            case char 1 to t2 of tItemContentsWithoutTabs is tUnRadio
            case char 1 to 3 of tItemContentsWithoutTabs is tBracket & tUnRadio
               put "Diamond" into tNewStyle
               put false into tNewHilite
               break
            default
               put "None" into tNewStyle
               put false into tNewHilite
         end switch
         if tNewStyle is not tValue["Style"] then put false into tAllSame["Style"]
      end if
      if tAllSame["Cascade"] then
         if tab is in tItemContents then put true into tNewValue
         else put false into tNewValue
         if tNewValue is not tValue["Cascade"] then put false into tAllSame["Cascade"]
      end if
      if tAllSame["disable"] then
         if char 1 to t1 of tItemContents is tBracket \
               or char 1 to t2 of tItemContents is tTab & tBracket \
               or tItemContents is tHyphen
         then put true into tNewValue
         else put false into tNewValue
         if tNewValue is not tValue["disable"] then put false into tAllSame["disable"]
      end if
      if tAllSame["numtabs"] then
         put empty into tNumTabs
         repeat for each char c in tItemContents
            if c is tab then add 1 to tNumTabs
         end repeat
         if tNumTabs is not tValue["numtabs"] then put false into tAllSame["numtabs"]
      end if     
   end repeat
   
   if tAllSame["Style"] then
      --all menu items same style
      set the label of btn "Item Style" to tValue["style"]
      set the backPattern of btn "Item Style" to empty
   else
      --menu items different style
      set the label of btn "Item Style" to tValue["style"]
      set the backPattern of btn "Item Style" to 200921
   end if
   
   --set hilite of Disable checkbox to a value if its the same for all the menu items, otherwise dim it out
   if tAllSame["Disable"] then
      set the hilite of btn "Item Disable" to tValue["Disable"]
      set the backPattern of btn "Item Disable" to empty
   else
      unhilite btn "Item Disable"
      set the backPattern of btn "Item Disable" to 200921
   end if
   --set hilite of Cascade checkbox to a value if its the same for all the menu items, otherwise dim it out
   if tAllSame["Cascade"] then
      set the hilite of btn "Cascade" to tValue["Cascade"]
      set the backPattern of btn "Cascade" to empty
   else
      unhilite btn "Cascade"
      set the backPattern of btn "Cascade" to 200921
   end if
   
   --hiliting of move right and move left btns which increase/decrease nesting of submenus
   if the num of items in the hilitedLines of me > 1 then put true into tMultipleSelection
   if item 1 of line (tFirstLine - 1) of gREVMMMenuItems is empty then put true into tItemAboveNotTriangle
   put item 3 of line tFirstLine of gREVMMMenuItems into tItemLine
   put line tItemLine of tText into tItemContents
   put line (tItemLine -1) of tText into tPrevItemContents
   put line (tItemLine +1) of tText into tNextItemContents
   --count tabs in previous menu item
   put empty into tSkip
   put empty into tOffset
   put empty into tPrevTabCount
   repeat
      put offset(tab,tPrevItemContents,tSkip) into tOffset
      add tOffset to tSkip
      if tOffset is 0 then exit repeat
      else add 1 to tPrevTabCount
   end repeat
   --count tabs in next menu item
   put empty into tSkip
   put empty into tOffset
   put empty into tNextTabCount
   repeat
      put offset(tab,tNextItemContents,tSkip) into tOffset
      add tOffset to tSkip
      if tOffset is 0 then exit repeat
      else add 1 to tNextTabCount
   end repeat
   
   put the hilitedLines of me into tTheHilitedLines
   if (the last item of tTheHilitedLines) - (the first item of tTheHilitedLines) + 1 is the num of items in tTheHilitedLines 
   then put true into tConsecutiveLines
   
   --hiliting of "Increase Item Nesting" icon
   put the hilitedLines of me into tTheHilitedLines
   
   --increase nesting button
   if tAllSame["numtabs"] and tAllSame["notfoldouttriangle"] and tConsecutiveLines \
         and tTheHilitedLines is not 1 and tItemAboveNotTriangle and tPrevTabCount >= tValue["numtabs"]
   then set the cREVDisabled of btn "Increase Item Nesting" to false
   else set the cREVDisabled of btn "Increase Item Nesting" to true
   
   --decrease nesting button
   if tAllSame["numtabs"] and tAllSame["notfoldouttriangle"] and tConsecutiveLines \
         and the hilite of btn "Cascade" and tNextTabCount <= tValue["numtabs"]
   then set the cREVDisabled of btn "Reduce Item Nesting" to false
   else set the cREVDisabled of btn "Reduce Item Nesting" to true
   
   if tMultipleSelection then
      --multiple menu items
      --disable shortcuts and renaming
      put empty into fld "Item Name"
      disable fld "Item Name"
      
      log "Unhilited due to multiple selection"
      
      disable btn "ShortCut Checkbox"
      set the cREVDisabled of btn "ShortCut" to true
      disable fld "Plus Label"
      unhilite btn "Item Mnemonic"
      disable btn "Item Mnemonic"
      unhilite btn "Shortcut Checkbox"
      put empty into fld "Shortcut"
      disable fld "Shortcut"
      disable btn "Item Mnemonic Letter"
      set the label of btn "Item Mnemonic Letter" to space  
      // SN-2014-11-26: [[ Bug 14072 ]] Add tag option in the menuManager
      put empty into fld "Item Tag"
      hilite btn "Item Tagged"
      disable btn "Item Tagged" 
   else
      --single menu item
      put line (item 3 of line (the hilitedLine of me) of gREVMMMenuItems) of tText into tItemContents
      // SN-2014-11-26: [[ Bug 14072 ]] Add tag option in the menuManager
      --tag
      put offset("|", tItemContents) into tOffset
      if tOffset is not 0 then
         put char tOffset + 1 to -1 of tItemContents into field "Item Tag"
         enable field "Item Tag"
         hilite button "Item Tagged"
         -- Clean the content, to get the same as before the update
         delete char tOffset to -1 of tItemContents
         
         -- SN-2015-01-07: [[ Bug 14341 ]] Remove the possibly added slash
         --  if the menu item has no shortcut
         if char -1 of tItemContents is slash then
            delete char -1 of tItemContents
         end if
      else
         put empty into field "Item Tag"
         disable field "Item Tag"
         unhilite button "Item Tagged"
         
         if tItemContents is tHyphen then
            disable btn "Item Tagged"
         end if
      end if
      
      --keyboard Control shortcut
      --if char - 2 of tItemContents is "/" and char - 1 of tItemContents is not "/" and char - 3 of tItemContents is not "/" then 
      if tItemContents contains "/" then
         hilite btn "Shortcut Checkbox"
         enable fld "Shortcut"
         put char -1 of tItemContents into fld "Shortcut"       
      else 
         unhilite btn "Shortcut Checkbox"
         disable fld "Shortcut"
         put empty into fld "Shortcut"
      end if
      -- Alt key mnemonic
      put empty into tSkip
      put empty into tOffset
      repeat
         put offset("&", tItemContents, tSkip) into tOffset
         add tOffset to tSkip
         if tOffset is 0 then 
            unhilite btn "Item Mnemonic"
            disable btn "Item Mnemonic Letter"
            set the label of btn "Item Mnemonic Letter" to space
            exit repeat
         else if char tSkip -1 of tItemContents is not "&" and char tSkip + 1 of tItemContents is not "&" then
            hilite btn "Item Mnemonic"
            enable btn "Item Mnemonic Letter"
            set the label of btn "Item Mnemonic Letter" to char tSkip + 1 of tItemContents
            exit repeat
         end if
      end repeat
      
      if not tUnicode then set the cREVDisabled of btn "ShortCut" to false
   end if
end revSetHilite

on revSetEnabled
   global gREVMMMenuItems, gREVActiveMenuButton
   
   if the text of me is not empty and the hilitedLines of me is not empty then
      --disable then enable to reliably enable everything in group
      disable grp "Menu Item Controls"
      enable grp "Menu Item Controls"
      if comma is in the effective textFont of gREVActiveMenuButton then
         disable btn "Item Mnemonic"
         disable btn "Item Mnemonic Letter"
         
         disable btn "Item Tagged"
         disable field "Item Tag"
         
         disable btn "Shortcut Checkbox"
         set the cREVDisabled of btn "Shortcut" to true
         
         disable fld "Shortcut"
         disable fld "Plus label"
      else
         enable btn "Shortcut Checkbox"
         set the cREVDisabled of btn "Shortcut" to false
      end if
      
      enable btn "Delete Item"
      enable fld "Item Name"
      enable fld "Mark Label"
      enable btn "Item Style"
      put the hilitedLines of me into tHilitedLines
      
      if the num of items in tHilitedLines is 1 then
         --count num tabs in previous,current and next line
         put item 2 of line (tHilitedLines -1) of gREVMMMenuItems into tMenuLine["prev"]
         put item 2 of line tHilitedLines of gREVMMMenuItems into tMenuLine["current"]
         put item 2 of line (tHilitedLines + 1) of gREVMMMenuItems into tMenuLine["next"]
         repeat for each item i in "prev,current,next"
            put 0 into tNumTabs[i]
            repeat for each char c in tMenuLine[i]
               if c is tab then add 1 to tNumTabs[i]
            end repeat
         end repeat
      end if
      
      if 1 is among the items of tHilitedLines or the num of items in tHilitedLines > 1 then 
         set the cREVDisabled of btn "Move Item Up" to true
      else 
         if (item 1 of line tHilitedLines of gREVMMMenuItems) or (item 1 of line (tHilitedLines - 1) of gREVMMMenuItems)\
         or (tNumTabs["current"] is not tNumTabs["prev"])
         then set the cREVDisabled of btn "Move Item Up" to true
         else set the cREVDisabled of btn "Move Item Up" to false
      end if
      if the num of lines in me is among the items of tHilitedLines or the num of items in tHilitedLines > 1 then
         set the cREVDisabled of btn "Move Item Down" to true
      else 
         if (item 1 of line tHilitedLines of gREVMMMenuItems) or (item 1 of line (tHilitedLines + 1) of gREVMMMenuItems)\
         or (tNumTabs["current"] is not tNumTabs["next"])
         then set the cREVDisabled of btn "Move Item Down" to true
         else set the cREVDisabled of btn "Move Item Down" to false
      end if
   else
      disable grp "Menu Item Controls"
      unhilite btn "Item Disable"
      unhilite btn "Item Mnemonic"
      unhilite btn "Shortcut Checkbox"
      set cREVDisabled of btn "Move Item Down" to true
      set the cREVDisabled of btn "Move Item Up" to true
      set the cREVDisabled of btn "Shortcut" to true
      disable btn "Item Mnemonic Letter"
      set the label of btn "Item Mnemonic Letter" to space
      disable btn "Delete Item"
      put empty into fld "Item Name"
      disable fld "Item Name"
      disable fld "Mark Label"
      disable btn "Item Style"
      
      // SN-2014-11-26: [[ bug 14972 ]] Add tag option in the menu Manager
      disable fld "Item Tag"
      put empty into field "Item Tag"
      disable btn "Item Tagged"
   end if
   
   -- Add code that updates the shortcut key controls.
   -- If multiple lines are hilited then just disable them all, otherwise,
   -- update them accordingly, using if possible, the code from updateControls.
   local tHilitedLine
   put line(the hilitedLine of me) of the text of me into tHilitedLine
   
   if tHilitedLine contains comma then
      disable button "Control"
      disable button "Command"
      disable button "Option_Alt"
      disable button "Shift"
   else
      // SN-2014-12-04: [[ Bug 11573 ]] Avoid to consider the tags as shortcuts
      local tSlashOffset, tTagOffset
      -- SN-2015-01-07: [[ Bug 14341 ]] The item delimiter is "|", not "/|"
      put offset("|", tHilitedLine) into tTagOffset
      
      if tTagOffset is not 0 then
         put offset(slash, char 1 to tTagOffset - 1 of tHilitedLine) into tSlashOffset
      else
         put offset(slash, tHilitedLine) into tSlashOffset
      end if
      
      if tSlashOffset = 0 then
         set the hilite of button "Shortcut Checkbox" to false
         set the hilite of button "Command" to false
         set the hilite of button "Control" to false
         set the hilite of button "Option_Alt" to false
         set the hilite of button "Shift" to false
         disable button "Control"
         disable button "Command"
         disable button "Shift"
         disable button "Option_Alt"
         disable field "Shortcut"
         set the text of field "Shortcut" to empty
         set the label of button "Shortcut" to empty
      else
         local tShortcut
         put char tSlashOffset + 1 to -1 of tHilitedLine into tShortcut
         local tShortcutKeys
         
         -- initialise
         set the hilite of button "Shortcut Checkbox" to true
         enable button "Control"
         enable button "Command"
         enable button "Option_Alt"
         enable button "Shift"
         set the hilite of button "Command" to "false"
         set the hilite of button "Control" to "false"
         set the hilite of button "Option_Alt" to "false"
         set the hilite of button "Shift" to "false"
         
         
         if tShortcut contains "%" then
            put true into tShortcutKeys["Control"]
         end if
         
         if tShortcut contains "@" then
            put true into tShortcutKeys["Shift"]
         end if
         
         if tShortcut contains "^" then
            put true into tShortcutKeys["Command"]
         end if
         
         if tShortcut contains "#" then
            put true into tShortcutKeys["Option_Alt"]
         end if
         
         if the keys of tShortcutKeys is empty then
            --Assume command
            set the hilite of button "Shortcut Checkbox" to true
            set the hilite of button "Command" to true
            set the hilite of button "Control" to false
            set the hilite of button "Option_Alt" to false
            set the hilite of button "Shift" to false
            set the label of button "Shortcut" to empty
            put char -1 of tMenuItem into field "Shortcut"
            -- need to correct the line in the menu
            --updateControls
            --updateMenuLine
            
            --set the hilite of button "Shortcut Checkbox" to false
            --disable button "Control"
            --disable button "Command"
            --disable button "Shift"
            --disable button "Option_Alt"
            --disable field "Shortcut"
            --set the text of field "Shortcut" to empty
            --set the label of button "Shortcut" to empty
         else
            set the hilite of button "Shortcut Checkbox" to true
            set the hilite of button "Control" to (tShortcutKeys["Control"] = true)
            set the hilite of button "Command" to (tShortcutKeys["Command"] = true)
            set the hilite of button "Shift" to (tShortcutKeys["Shift"] = true)
            set the hilite of button "Option_Alt" to (tShortcutKeys["Option_Alt"] = true)
            --enable field "Shortcut"
            --enable button "Control"
            --enable button "Command"
            --enable button "Option_Alt"
            --enable button "Shift"
            set the label of button "Shortcut" to empty
            put char -1 of tMenuItem into field "Shortcut"
         end if
         delete char tSlashOffset to -1 of tMenuItem
      end if
   end if
   --updateControls line (the hilitedLine of me) of the text of me
end revSetEnabled

on revSetWidgetPosition
  if the hilitedLines of me is empty then exit revSetWidgetPosition
  put the last item of the hilitedLines of me into tBottomHilitedLine
  put the formattedTop of line tBottomHilitedLine of me + 7 into tTop
  if tTop > the bottom of me then set the top of grp "Item Insert" to - 1000
  else set the top of grp "Item Insert" to tTop
  set the cREVLine of grp "Item Insert" to tBottomHilitedLine
end revSetWidgetPosition

on scrollbarDrag
  lock messages
  set the thumbPosition of sb "Menu Items" to the scroll of me
  revResetTriangles
  unlock messages
end scrollbarDrag

on deleteKey
  click at the loc of btn "Delete Item"
end deleteKey
