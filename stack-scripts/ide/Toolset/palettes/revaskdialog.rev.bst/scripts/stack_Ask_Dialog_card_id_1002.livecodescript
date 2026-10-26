script "stack_Ask_Dialog_card_id_1002"
-- Stack file: ide/Toolset/palettes/revaskdialog.rev
-- Object: stack "Ask Dialog" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on doresize
   // AL-2014-05-21: [[ Bug 12074 ]] Support RTL layout when resizing ask dialog
   local tRTL
   put the cRTL of this card into tRTL
   
   local twidth, iwidth
   put the width of this stack into twidth
   if item 1 of the loc of button "icon" is not "-100" then 
      local tIconEdge
      if tRTL then
         put the left of button "icon" into tIconEdge
         subtract 8 from tIconEdge
      else
         put the right of button "icon" into tIconEdge
         add 8 to tIconEdge
      end if
      subtract the width of button "icon" from tWidth
   else       
      if tRTL then
         put twidth - 24 into tIconEdge
      else
         put 24 into tIconEdge
      end if
   end if
   set the width of field 1 to twidth - 48
   set the width of field 2 to twidth - 48
   
   if tRTL then
      set the right of field 1 to tIconEdge
      set the right of field 2 to tIconEdge
   else
      set the left of field 1 to tIconEdge
      set the left of field 2 to tIconEdge
   end if
   set the top of field 2 to the bottom of field 1 + 4
   set the top of button 1 to the height of field 1 div 2 - 8
   set the default of button "OK" to false
   
   local tFirstWidthOffset, tFirstBottomOffset, tSecondLeftOffset, tSecondBottomOffset
   local tFirst, tSecond, tFirstXOffset, tFirstYOffset, tSecondXOffset, tSecondYOffset
   put 21 into tFirstXOffset
   put 18 into tFirstYOffset
   put 14 into tSecondXOffset
   put 18 into tSecondYOffset
   
   set the textFont of button "OK" to "usesystemfont"
   set the textSize of button "OK" to 13
   set the textFont of button "Cancel" to "usesystemfont"
   set the textSize of button "Cancel" to 13
   
   // AL-2014-05-21: [[ Bug 11493 ]] Linux confirmation button should be on the right
   if the platform is in "MacOSLinux" then
      put "OK" into tFirst
      put "Cancel" into tSecond
   else
      put "Cancel" into tFirst
      put "OK" into tSecond
   end if
   set the default of button "OK" to true
   
   if tRTL then
      set the bottomLeft of button tFirst to (tFirstXOffset, the bottom of this card - tFirstYOffset)
      set the bottomLeft of button tSecond to (the right of button tFirst + tSecondXOffset, the bottom of this card - tSecondYOffset)
   else
      set the bottomRight of button tFirst to (the width of this card - tFirstXOffset, the bottom of this card - tFirstYOffset)
      set the bottomRight of button tSecond to (the left of button tFirst - tSecondXOffset, the bottom of this card - tSecondYOffset)
   end if
end doresize

on star
  local tstring
  put empty into tstring
  repeat with i = 1 to the number of characters in field 3
    put "*" after tstring
  end repeat
  put tstring into field 2
end star

on preOpenStack
   -- PM-2015-07-23: [[ Bug 14224 ]] Remove the (old) focus to allow typing into the input fld
   focus on nothing
   
   global gREVAppIcon, gREVSmallAppIcon
   local twidth
   set the itemDelimiter to numToChar(0)
   set the fieldmode of me to word 2 of item 1 of the dialogData
   if item 2 of the dialogData is empty
   then set the title of this stack to space
   else set the title of this stack to item 2 of the dialogData
   
   -- MW-2007-12-11: [[ Bug 4974 ]] Support the use of htmlText in the prompt
   local tText
   put item 3 of the dialogData into tText
   if "<p>" is in tText or matchChunk(tText, "<(.+>.+</.+)>") then
      set the htmlText of field 1 to tText
   else
      put item 3 of the dialogData into field 1
   end if
   
   
   set the itemDel to comma
   set the icon of button "icon 2" to 0
   set the loc of button "icon 2" to -200,-200
   
   local tStackLoc
   local tScreenRect
   put line (the screen of this stack) of the screenRects into tScreenRect
   
   local tScreenWidth
   put item 3 of tScreenRect - item 1 of tScreenRect into tScreenWidth
   
   local tScreenHeight
   put item 4 of tScreenRect - item 2 of tScreenRect into tScreenHeight
   
   put item 1 of tScreenRect + (tScreenWidth div 2),item 2 of tScreenRect + (tScreenHeight div 2) into tStackLoc
   
   switch the platform
      case "MacOS"
         local tMacOSX
         put true into tMacOSX
         set the loc of this stack to tStackLoc
         set the top of this stack to item 2 of tScreenRect + round(tScreenHeight/5)
         repeat with i = 3 to the number of btns
            set the margins of button i to 4
            set the height of button i to 23
         end repeat
         set the textFont of this stack to "Lucida Grande"
         set the textSize of this stack to 13
         set the textFont of field 1 to empty
         set the textSize of field 1 to 13
         local tIcons
         put "210093 210092 210094 210093" into tIcons
         
         break
      case "Win32"
         
         # OK-2007-11-05 : gREVLargeFonts was undeclared...
         global gREVLargeFonts
         if gREVLargeFonts then
            local tNumber
            put 26 into tNumber
            
            local tMargin
            put 7 into tMargin
         else
            put 23 into tNumber
            put 3 into tMargin
         end if
         repeat with i = 3 to the number of btns
            set the bottomMargin of button i to tMargin
            set the height of button i to tNumber
            set the traversalOn of button i to false
            set the mnemonic of button i to 0
         end repeat         
         ## Removed by EJB 18/07/2013 - Bug 11054
         ## Cleared so uses default font and size
         ##set the textFont of this stack to "MS Sans Serif"
         ##set the textSize of this stack to 10
         set the textFont of this stack to empty
         set the textSize of this stack to empty
         
         set the textFont of field 1 to empty
         put "210005 210011 210003 210004" into tIcons
         break
      default
         repeat with i = 3 to the number of btns
            set the bottomMargin of button i to 4
            set the height of button i to 22
            set the traversalOn of button i to false
            set the mnemonic of button i to 0
         end repeat
         set the textFont of this stack to "Helvetica"
         
         # OK-2007-11-05 : gAPKLargeFonts was undeclared...
         global gAPKLargeFonts
         
         if gAPKLargeFonts then 
            set the textSize of this stack to 14
         else 
            set the textSize of this stack to 12
         end if
         set the textFont of field 1 to empty
         put "210008 210010 210006 210010" into tIcons
         break
   end switch
   
   # TH-11-01-2008: Bug fix for 4913, need to set the field size after the font sizes have been
   # adjusted to prevent clipping of text
   put max(the formattedWidth of field 1 + 48,\\
         the formattedWidth of field 2 + 64, 450) into twidth
   set the width of this stack to twidth
   set the height of field 1 to the formattedHeight of field 1 -- + 25
   set the top of field 1 to 8
   set the height of this stack to (the height of field 1) + 88
   
   set the itemDel to numToChar(0)
   if the fieldmode of me is "password" or the fieldmode of me is "clear" then
      put item 4 of the dialogData into field 3
      star
   else put item 4 of the dialogData into field 2
   
   // AL-2014-05-21: [[ Bug 12074 ]] Support RTL layout for ask dialog
   local tRTL
   get item 5 of the dialogdata 
   if it is empty then
      put false into tRTL
   else
      put it is "true" into tRTL
   end if
   
   -- field alignment
   if tRTL then
      set the textAlign of field 1 to "right"
      set the textAlign of field 2 to "right"
   else
      set the textAlign of field 1 to "left"
      set the textAlign of field 2 to "left"
   end if
   
   set the cRTL of this card to tRTL
   
   local tIconX, tIconY
   if word 2 of item 1 of the dialogData is "plain" and (not tMacOSX and gREVAppIcon is not empty) then
      set the loc of button 1 to -100,21
   else
      if tMacOSX then
         put 52 into tIconX
         put 44 into tIconY
      else
         put 26 into tIconX
         put 33 into tIconY
      end if
      
      local tIconWord
      put wordOffset(word 2 of item 1 of the dialogData, "information error warning question") into tIconWord
      
      ------------------- app icon ---------------
      if there is a stack "revGeneralIcons" then
         if the platform contains "mac" then put the ID of image "oxt-l-64.png" of cd "theAlertIcons" of stack "revGeneralIcons" into gRevAppIcon
         if not (the platform contains "mac") then put the ID of image "oxt-l-32.png" of cd "theAlertIcons" of stack "revGeneralIcons" into gRevAppIcon
         set the icon of button "Icon" of this card to gRevAppIcon
      end if
      --
      put "87" into tIconAllowance
      if there is a stack "revCopiedIcons" then
         -- we are in a standalone, a mac standalone
         -- try and find the icons elsewhere
         if there is a card 2 of stack "revCopiedIcons" then
            put the ID of image "oxt-l-64.png" of cd "theAlertIcons" of stack "revCopiedIcons" into gRevAppIcon
            set the icon of button "Icon" of this card to gRevAppIcon
         end if
      end if
      --------------------------------------------
      
      if tMacOSX then set the icon of button "icon" to gREVAppIcon
      /*
      if tMacOSX and tIconWord is 0 then --large app icon
         set the icon of button "icon" to "210112"
      else
         set the icon of button "icon" to word tIconWord of tIcons
      end if
      */
      
      // AL-2014-05-21: [[ Bug 4001 ]] Make sure icon button has autohilite false
      set the autohilite of button "icon" to false
      
      if tRTL then put tWidth - tIconX into tIconX
      set the loc of button "icon" to tIconX, tIconY
   end if
   
   set the dialogData to numToChar(0)
   doresize
end preOpenStack

on keyDown which
  local tpos
  if the name of the target contains "field" and word 1 of the fieldmode of me is "password" or the fieldmode of me is "clear" then
    put the selectedChunk into tpos
    put which into character (word 2 of tpos) to (word 4 of tpos) of field 3
    star
    select after character (word 2 of tpos) of field 2
  else pass keyDown
end keyDown

on deleteKey
   -- PM-2015-07-24: [[ Bug 3962 ]] Pass deleteKey when 'ask plain/question/information/warning/error ..'
  if the fieldmode of me is "password" or the fieldmode of me is "clear" then
      if word 2 of the selectedchunk > word 4 of the selectedchunk then
         deleteone "forward"
      else
         # TH-2008-06-23 :: Bug 6491
         local tChunk
         put the selectedChunk into tChunk
         deleteChunk tChunk
      end if
   else 
      pass deleteKey
   end if
end deleteKey

# OK-2007-11-05 : Bug 3956
on escapeKey
  closeReject
end escapeKey

on backspaceKey
   if the fieldmode of me is "password" or the fieldmode of me is "clear" then
      if word 2 of the selectedchunk > word 4 of the selectedchunk then
         deleteone "back"
      else
         # TH-2008-06-23 :: Bug 6491
         local tChunk
         put the selectedChunk into tChunk
         deleteChunk tChunk
      end if
   else 
      pass backSpaceKey
   end if
end backspaceKey
  

# TH-2008-06-23 :: Bug 6491, make the delete and backspace keys delete
# hilited text
command deleteChunk pChunk
   local tStartChar, tEndChar
   put word 2 of pChunk into tStartChar
   put word 4 of pChunk into tEndChar
   put empty into char tStartChar to tEndChar of field 3
   star
   select before char tStartChar of field 2     
end deleteChunk
  
on deleteone pDirection
   local tpos
   put word 2 of the selectedChunk into tpos
   
   if pDirection is "back" then    -- backSpace key is pressed
      put empty into character (tpos - 1) of field 3
      star
      select before character (tpos - 1) of field 2
   else if pDirection is "forward" then     -- delete key is pressed
      put empty into character (tpos) of field 3
      star
      select before character (tpos) of field 2
   end if
end deleteone

on commandKeyDown which
  if which is "." then
    #click at the loc of button "Cancel"
    closeReject
    exit commandKeyDown
  end if
  if the fieldmode of me is not "plain"
  then
    local tpos
    switch which
    case "D"
      put word 2 of the selectedChunk into tpos
      put empty into character tpos of field 3
      star
      select before character tpos of field 1
      break
    case "H"
      deleteone "back"
      break
    default
      pass commandKeyDown
    end switch
  else pass commandKeyDown
end commandKeyDown

on openField
  select the text of the target
end openField

on resizeStack
  doresize
end resizeStack

on returnInField
  #click at the loc of button "OK"
  closeAccept
end returnInField

on enterInField
  returnInField
end enterInField

on closeStack
  revCleanUpAskDialog
end closeStack

on revCleanUpAskDialog
  put empty into field 1
  put empty into field 2
  put empty into field 3
end revCleanUpAskDialog

# OK-2007-11-05 : Bug 3956

command closeAccept
   local tResult
   switch the fieldmode of this card
      case "plain"
      case "question"
      case "error"
      case "information"
      case "warning"
         put the text of field 2 of me into tResult
         break
      case "clear"
         put the text of field 3 of me into tResult
         break
      case "password"
         --put mcencrypt(the text of field 3 of me) into tResult
         -- MM-2013-01-28: [[ Bug 10037 ]] No longer hash passwords.
         put the text of field 3 of me into tResult
         break
   end switch
   
   set the dialogData to tResult
   lock messages
   close this stack
   revCleanUpAskDialog
   unlock messages
end closeAccept

command closeReject
  lock messages
  close this stack
  revCleanUpAskDialog
  unlock messages
end closeReject




