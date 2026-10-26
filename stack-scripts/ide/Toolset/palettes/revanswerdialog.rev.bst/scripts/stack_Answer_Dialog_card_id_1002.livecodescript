script "stack_Answer_Dialog_card_id_1002"
-- Stack file: ide/Toolset/palettes/revanswerdialog.rev
-- Object: stack "Answer Dialog" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   global gAnswerDebugInfo, gAPKLargeFonts, gREVSmallAppIcon, gREVAppIcon
   local tIcons, tMacOSX, tMargin, tNumber, tIconWord, tIconAllowance, tText, tButtonNames, tNoOfButtons, tTotalBtnWidth
   local tMnemonicString, tNo, tFieldScript, tFieldSubtract, tWidth, tNewWidth, OldWidth, tAddition, tStartEdge, tHeight
   
   --AL-2014-05-21: [[ Bug 12074 ]] Tidied up and rearranged to support RTL layout, as determined by item 5 of the dialogData
   set the default of button 3 to false
   set the bottomRight of button "Icon 2" to "-100,-100"
   switch the platform  --platform specific font adjustments
      case "MacOS"
         --if char 1 of the systemVersion is "1" then  -- OSX
         put true into tMacOSX
         set the loc of this stack to the screenLoc
         set the top of this stack to round(item 4 of the screenRect/5)
         repeat with i = 3 to the number of btns
            set the margins of button i to "4"
            set the height of button i to "23"
         end repeat
         set the textFont of this stack to "Lucida Grande"
         set the textSize of this stack to "13"
         set the textSize of field 1 of me to "13"
         put "210093 210092 210094 210097" into tIcons
         if there is a stack "revCopiedIcons" then
            -- we are in an OSX standalone
            -- try and find the icons elsewhere
            if there is a card 2 of stack "revCopiedIcons" then
               put "" into tIcons
               put the ID of image "Info.png" of cd "theAlertIcons" of stack "revCopiedIcons" into line 1 of tIcons
               put the ID of image "Error.png" of cd "theAlertIcons" of stack "revCopiedIcons" into line 2 of tIcons
               put the ID of image "Warning.png" of cd "theAlertIcons" of stack "revCopiedIcons" into line 3 of tIcons
               put the ID of image "Answer Info.png" of cd "theAlertIcons" of stack "revCopiedIcons" into line 4 of tIcons
               replace return with " " in tIcons
            end if
         end if
         /*else
         /* these are MacOS 9 icons. Commented out. Unused    
         set the loc of this stack to the screenLoc
         set the top of this stack to round(item 4 of the screenRect/5)
         repeat with i = 3 to the number of btns
            set the bottomMargin of button i to "3"
            set the height of button i to "20"
         end repeat
         set the textFont of this stack to "usesystemfont"
         set the textSize of this stack to "12"
         set the textFont of field 1 of me to "usesystemfont"
         set the textSize of field 1 of me to "12"
         put "210002 210001 210012 210009" into tIcons
      end if
      */
      break
   case "Linux"
      set the loc of this stack to the screenLoc
      set the top of this stack to round(item 4 of the screenRect/5)
      repeat with i = 3 to the number of btns
         set the bottomMargin of button i to "3"
         set the height of button i to "20"
      end repeat
      set the textFont of this stack to "usesystemfont"
      set the textSize of this stack to "12"
      set the textFont of field 1 of me to "usesystemfont"
      set the textSize of field 1 of me to "12"
      put "210005 210011 210003 210004" into tIcons
      if there is a stack "revCopiedIcons" then
         -- we are in a linux standalone
         -- try and find the icons elsewhere
         if there is a card 2 of stack "revCopiedIcons" then
            put "" into tIcons
            put the ID of image "ic-210005" of cd "theAlertIcons" of stack "revCopiedIcons" into line 1 of tIcons
            put the ID of image "ic-210011" of cd "theAlertIcons" of stack "revCopiedIcons" into line 2 of tIcons
            put the ID of image "ic-210003" of cd "theAlertIcons" of stack "revCopiedIcons" into line 3 of tIcons
            put the ID of image "ic-210004" of cd "theAlertIcons" of stack "revCopiedIcons" into line 4 of tIcons
            replace return with " " in tIcons
         end if
      end if
      break
   case "Win32"
      if gAPKLargeFonts then
         put "26" into tNumber
         put "7" into tMargin
      else
         put "21" into tNumber
         put "5" into tMargin
      end if
      repeat with i = 3 to the number of btns
         set the bottomMargin of button i to tMargin
         set the height of button i to tNumber
         set the traversalOn of button i to false
         set the mnemonic of button i to "0"
      end repeat
      set the textFont of this stack to empty  --EJB 18/07/2013 - Bug 11054, use default font and size
      set the textSize of this stack to empty
      set the textFont of field 1 of me to empty
      put "210005 210011 210003 210004" into tIcons
      if there is a stack "revCopiedIcons" then
         -- we are in a Windows standalone
         -- try and find the icons elsewhere
         if there is a card 2 of stack "revCopiedIcons" then
            put "" into tIcons
            put the ID of image "ic-210005" of cd "theAlertIcons" of stack "revCopiedIcons" into line 1 of tIcons
            put the ID of image "ic-210011" of cd "theAlertIcons" of stack "revCopiedIcons" into line 2 of tIcons
            put the ID of image "ic-210003" of cd "theAlertIcons" of stack "revCopiedIcons" into line 3 of tIcons
            put the ID of image "ic-210004" of cd "theAlertIcons" of stack "revCopiedIcons" into line 4 of tIcons
            replace return with " " in tIcons
         end if
      end if
      break
   default
      repeat with i = 3 to the number of btns
         set the bottomMargin of button i to "4"
         set the height of button i to "22"
         set the mnemonic of button i to "0"
      end repeat
      set the textFont of this stack to "(System)"
      if gAPKLargeFonts then set the textSize of this stack to "14"
      else set the textSize of this stack to "12"
      set the textFont of field 1 of me to empty
      put "210008 210010 210006 210010" into tIcons
      break
end switch

set the itemDel to numToChar(0)
local tRTL
put item 5 of the dialogData into tRTL  --true/false/empty
if tRTL is empty then put false into tRTL
if tRTL then set the textAlign of field 1 to "right"  --field alignment
else set the textAlign of field 1 to "left"

local tHasIcon, tIconX, tIconTop

put fld id 1006 & tIconWord into fld id 1006 of this card
if word 2 of item 1 of the dialogData is "empty" then
   set the loc of button 1 to "-100,21"
   put "0" into tIconAllowance
   put false into tHasIcon
else  --display icon
   put true into tHasIcon
   if tMacOSX then
      set the width of btn "Icon" to 64
      set the height of btn "Icon" to 64
      put "87" into tIconAllowance
      put "52" into tIconX
      put "18" into tIconTop
   else
      set the width of btn "Icon" to 32
      set the height of btn "Icon" to 32
      put "40" into tIconAllowance
      put "26" into tIconX
      put "6" into tIconTop
   end if
end if

-- if no icon specified, hide it. (use "plain" to use OXT icon)
put wordOffset(word 2 of item 1 of the dialogData, "information error warning question plain") into tIconWord
if tIconWord is "5" then
   -- set icon to app icon
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
   if not (the platform contains "mac") then
      if there is a stack "revCopiedIcons" then
         -- we are in a standalone, a linux or a windows standalone
         -- try and find the icons elsewhere
         if there is a card 2 of stack "revCopiedIcons" then
            put the ID of image "oxt-l-32.png" of cd "theAlertIcons" of stack "revCopiedIcons" into gRevAppIcon
            set the icon of button "Icon" of this card to gRevAppIcon
         end if
      end if
      put "42" into tIconAllowance
      put "26" into tIconX
      set the left of fld 1 to "3"
      put "6" into tIconTop
      show btn "Icon" of this stack
   end if
   put true into tHasIcon
   show btn "Icon" of this stack
   put item 3 of the dialogData into tText
   if word 1 of tText is "nullifyIcon" then
      -- we don't want an icon
      delete word 1 of tText
      set the icon of button "Icon" of this card to ""
      put false into tHasIcon
      hide btn "Icon" of this stack
      put "0" into tIconAllowance
   end if
   if there is an image "appicon.png" of card 1 of the topstack then
      put "87" into tIconAllowance
      if not (the platform contains "mac") then
         set the width of button "icon" to the width of image "appicon.png" of cd 1 of the topstack
         set the height of button "icon" to the height of image "appicon.png" of cd 1 of the topstack
         put the width of image "appicon.png" of cd 1 of the topstack +12 into tIconAllowance
         put "42" into tIconX
         set the left of fld 1 to "3"
         put "6" into tIconTop
         show btn "Icon" of this stack
      else
         set the width of button "icon" to the width of image "appicon.png" of cd 1 of the topstack
         set the height of button "icon" to the height of image "appicon.png" of cd 1 of the topstack
      end if
      set the icon of button "Icon" of this card to the id of image "appicon.png" of cd 1 of the topstack
      put true into tHasIcon
      show btn "Icon" of this stack
   end if
else
   -- set icon to what user specified
   put "87" into tIconAllowance
   if not (the platform contains "mac") then
      put "42" into tIconAllowance
      put "26" into tIconX
      set the left of fld 1 to "3"
      put "6" into tIconTop
      show btn "Icon" of this stack
   end if
   set the icon of button "Icon" to word tIconWord of tIcons
   put true into tHasIcon
   show btn "Icon" of this stack
   
   --
   
end if

/*
if tIconWord >5 then 
   put false into tHasIcon
   put "0" into tIconAllowance
   hide button "Icon"
   put "52" into tIconX
   put "18" into tIconTop
   
   -------------------------------------------------------------------------------------------------------------
   ------------------- let's check if there are any stacks with an 'appicon.png' on card 1 ------------------
   put the openStacks into tOpenstacks
   filter lines of tOpenstacks without "rev*"
   filter lines of tOpenstacks without "Message Box"
   filter lines of tOpenstacks without "App Browser"
   filter lines of tOpenstacks without "Script Editor"
   put 0 into tStackCount
   put false into tHasCustomStackIcon
   repeat the number of lines in tOpenstacks
      add 1 to tStackCount
      if there is a stack (line tStackCount of tOpenstacks) then
         -- stack exists, and I don't think it's part of the IDE, so lets search through it
         if there is an image "appicon.png" of card 1 of stack (line tStackCount of tOpenstacks) then
            -- stop, found our image
            -- put "image found in " & line tStackCount of tOpenstacks & " stack." -- debug
            put true into tHasCustomStackIcon
            put line tStackCount of tOpenstacks into tStackWithCustomIcon
            exit repeat
         end if
      end if
   end repeat
   if tHasCustomStackIcon is true then
      -- load the custom icon
      put the id of image "appicon.png" of card 1 of stack tStackWithCustomIcon into tNewIconID
      set the icon of button "Icon" to tNewIconID
      put true into tHasIcon
      show button "Icon"
      put "87" into tIconAllowance
   else
      -- use the standard app icon (if we specify "plain")
      set the icon of button "Icon" of this card to "210112"
      put true into tHasIcon
      show button "Icon"
      put "87" into tIconAllowance
   end if
end if
*/
---------------------------------- end checks for custom alert icons -------------------------------------
-------------------------------------------------------------------------------------------------------------

if item 2 of the dialogData is empty then set the title of this stack to space  --title
else set the title of this stack to item 2 of the dialogData
put item 3 of the dialogData into tText
if word 1 of tText is "nullifyIcon" then delete word 1 of tText
if "<p>" is in tText or matchChunk(tText, "<(.+>.+</.+)>") then set the htmlText of field 1 of me to tText
else set the text of field 1 of me to tText


local tButtonNamesList, tButtonLimit
put item 4 of the dialogData into tButtonNamesList
put "7" into tButtonLimit  --TH-2008-02-07, Bug 6427, display all buttons specified up to tButtonLimit
repeat with x = 1 to min(tButtonLimit, the number of lines of tButtonNamesList)
   put line x of tButtonNamesList & return after tButtonNames
end repeat
delete last char of tButtonNames  --cr
if tButtonNames is empty then put "OK" into tButtonNames
put the number of lines in tButtonNames into tNoOfButtons
put "32" into tTotalBtnWidth

if tNoOfButtons > the number of buttons - 2 then put the number of buttons - 2 into tNoOfButtons  --truncate btns to max allowed
put empty into tMnemonicString
repeat with i = 3 to (tNoOfButtons + 3)
   set the name of button i to line tNoOfButtons - (i - 3) of tButtonNames
   if the platform is "Win32" and the short name of button i is not in "OKCancel" then
      put "0" into tNo
      repeat for each char x in the short name of button i
         add 1 to tNo
         if x is not in tMnemonicString then
            put x after tMnemonicString
            set the mnemonic of button i to tNo
            exit repeat
         end if
      end repeat
   end if
   set the width of button i to "82"
   if the width of button i < the formattedWidth of button i +28 then set the width of button i to the formattedWidth of button i + 28
   add the width of button i + 12 to tTotalBtnWidth
end repeat
set the dontWrap of field 1 of me to true
if tMacOSX then put "4" into tFieldSubtract else put "0" into tFieldSubtract
--Marcus, [[ bug 4830 ]], wrap 2nd max around calculations below
put max(400, max(the formattedWidth of field 1 of me + tIconAllowance + 16, tTotalBtnWidth) + tFieldSubtract) into tWidth
if tWidth > "400" then  --wrap text, recalculate width
   set the width of field 1 of me to "1"
   set the dontWrap of field 1 of me to false
   put max(400, max(the formattedWidth of field 1 of me + tIconAllowance + 16, tTotalBtnWidth) + tFieldSubtract) into tWidth
end if
put the width of this stack into OldWidth
set the width of this stack to tWidth

if tHasIcon then  --reposition icon if new stack width
   if tRTL then put tWidth - tIconX into tIconX
   set the loc of button "Icon" to tIconX,0
   set the top of button "Icon" to tIconTop
end if

set the itemDel to comma
if tRTL then      
   set the topRight of field 1 of me to tWidth - (tIconAllowance + 8), 12
   get the rect of field 1 of me
   put "12" into item 1 of it
else
   set the topLeft of field 1 of me to tIconAllowance + 8, 12
   get the rect of field 1 of me
   put tWidth - 12 into item 3 of it
end if
set the rect of field 1 of me to it

if tMacOSX then put "5" into tAddition
else put "0" into tAddition
if tRTL then put 12 + tAddition into tStartEdge
else put tWidth -12 - tAddition into tStartEdge

put the formattedHeight of field 1 of me + 58 into tHeight  --[[ Bug 17001 ]] Ensure dialog is tall enough for icon + margin
if tHasIcon then put max(tHeight, the bottom of btn "Icon" + tIconTop) into tHeight

if tHeight > "400" then
   set the vScrollbar of field 1 of me to true
   put "400" into tHeight
else set the vScrollbar of field 1 of me to false
local tTop
put the top of field 1 of me into tTop
set the height of this stack to tHeight
set the height of field 1 of me to tHeight - 58
set the top of field 1 of me to tTop
--set the topLeft of field 1 of me to tIconAllowance + 8, 12

if the platform is in "MacOSLinux" then  --AL-2014-05-21: [[ Bug 11493 ]] Linux confirmation btn on right
   if tMacOSX then put "6" into tAddition
   else put "0" into tAddition
   repeat with i = 3 to tNoOfButtons + 2
      if tRTL then
         set the left of button i to tStartEdge
         add the width of button i + 10 to tStartEdge
      else
         set the right of button i to tStartEdge        
         subtract the width of button i + 10 from tStartEdge
      end if
      set the bottom of button i to the height of this stack - 12 - tAddition
      if i is "5" and tNoOfButtons is "3" and word 1 of the short name of button i is "Don't" then  --move "Don't Save" to the side
         if tRTL then set the right of button i to the right of field 1 of me - 5
         else set the left of button i to the left of field 1 of me + 5
      end if
   end repeat
else
   repeat with i = (tNoOfButtons + 2) down to 3
      if tRTL then
         set the left of button i to tStartEdge
         add the width of button i + 12 to tStartEdge
      else
         set the right of button i to tStartEdge        
         subtract the width of button i + 12 from tStartEdge
      end if
      set the bottom of button i to the height of this stack - 12
      set the traversalOn of button i to true
   end repeat
end if
if the platform is "MacOS" then set the top of this stack to round(item 4 of the screenRect/5)
else  --keyboard nav on windows & linux
   repeat with i = (tNoOfButtons +2) down to 3
      set the traversalOn of button i to true
   end repeat
end if
set the default of button 3 to true
-- OXT-Beyond: the whole dialog on the screen
revAnswerDialogOnScreen
end preOpenStack

-- OXT-Beyond: moves the dialog into the working area of its screen when
-- part of it, its title bar included, is outside it; one larger than the
-- area goes to its top left. The engine centred the dialog on the stack
-- it was asked from before preOpenStack sized it to its text, so a long
-- message asked from a window near the top of the screen grew past it.
on revAnswerDialogOnScreen
   local tArea, tRect, tFrame, tTitle, tEdge, tLeft, tTop
   put line (the screen of this stack) of the working screenRects into tArea
   if the number of items of tArea is not 4 then put the working screenRect into tArea
   -- An engine with no screen (no user interface) leaves it alone
   if item 3 of tArea <= item 1 of tArea or item 4 of tArea <= item 2 of tArea then exit revAnswerDialogOnScreen
   put the rect of this stack into tRect
   put the effective rect of this stack into tFrame
   -- The window's frame: its title bar above the card, a border round it
   -- (at least as much as the platforms draw, when the window has none yet)
   put max(32, item 2 of tRect - item 2 of tFrame) into tTitle
   put max(8, item 1 of tRect - item 1 of tFrame) into tEdge
   put max(item 1 of tArea + tEdge, min(item 1 of tRect, item 3 of tArea - tEdge - (item 3 of tRect - item 1 of tRect))) into tLeft
   put max(item 2 of tArea + tTitle, min(item 2 of tRect, item 4 of tArea - tEdge - (item 4 of tRect - item 2 of tRect))) into tTop
   if tLeft is not item 1 of tRect or tTop is not item 2 of tRect then
      set the topLeft of this stack to tLeft, tTop
   end if
end revAnswerDialogOnScreen

on commandKeyDown pKey
   if pKey is "." then
      if there is a button "Cancel" then
         click at the loc of button "Cancel"
         exit commandKeyDown
      end if
   end if
   repeat with i = 3 to the number of btns
      if item 1 of the loc of button i < "1" then next repeat
      if char 1 of the short name of button i is pKey then
         set the hilite of button i to true
         wait 50 milliseconds
         set the hilite of button i to false
         send "mouseUp" to button i
         exit repeat
      end if
   end repeat
end commandKeyDown

on escapeKey
  if there is a button "Cancel" then click at the loc of button "Cancel"
end escapeKey

on closeStack
  revCleanUpAnswerDialog
end closeStack

on revCleanUpAnswerDialog
   repeat with i = 3 to the number of buttons
      set the cPrevLoc of button i to the loc of button i
      set the loc of button i to "-100,-100"
   end repeat
   set the dialogData to empty
   --if the environment is "development" then  --for v9
      --send "ideMessageSend" && "ideAnswerDialogClosed" to stack "revIDELibrary" in 0 millisecs
   --end if
end revCleanUpAnswerDialog

on mouseUp  --transmit the dialogData
   if the name of the target contains "button" then
      lock messages--prevents user stack getting refocusing messages
      close this stack
      revCleanUpAnswerDialog--won't get closeStack
      unlock messages
      set the dialogData to the short name of the target
   end if
end mouseUp

on returnKey
   pass returnKey to top
end returnKey

on linkClicked pLink
   if "@" is in pLink then revMail pLink
   else revGoURL pLink
end linkClicked

on debugLog pMsg, pDel
   --global gAnswerDebugInfo
   --repeat for each line tLine in pMsg
   --put pDel & tLine & return after gAnswerDebugInfo
   --end repeat
end debugLog

on tCheckSmallerIcon
   -- adjust for small icons for Linux & windows
   if not (the platform contains "mac") then
      put "42" into tIconAllowance
      put "26" into tIconX
      set the left of fld 1 to "3"
      put "6" into tIconTop
      
   end if
end tCheckSmallerIcon
