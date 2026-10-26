script "stack_App_Browser_field_id_1037"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > field "Controls" (id 1037)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kTabs="Type,Visible,Selectable,Layer,Control,ID,Script Lines"
local lTypeText, lClearTimerID

on mouseDown pButton
  revSelectInListField the long id of me, pButton
  if the num of words in the text of me > 0 then selectionChanged
  if the platform is "MacOS" and pButton is 3 then revControlFieldPopup
end mouseDown

on mouseUp pButton
   global gREVControls, gREVStackName
   if the platform is not "MacOS" and pButton is 3 then 
      revControlFieldPopup
      pass mouseUp
   end if
   
   local tClickH
   put the clickH into tClickH
   
   local tLine
   put revFieldMouseLine(the long id of me) into tLine
   
   local tLayer
   put item itemOffset("Layer", kTabs) of line tLine of gREVControls into tLayer
   
   # OK-2010-04-19: Use tOwner instead of card when accessing control because of edit group mode.
   local tOwner
   if there is a card id (the cCardID of this stack) of stack gREVStackName then
      put revGetOwnerReference(the long id of card id (the cCardID of this stack) of stack gREVStackName) into tOwner
   end if
   
   local tControl
   if tOwner is not empty then
      if exists (the long id of control tLayer of tOwner) then put the long id of control tLayer of tOwner into tControl -- check tOwner exists first 28-11-23 (tperry)
   end if
   
   if tControl is empty then
      pass mouseUp
   end if
   
   local tVisibleoffset
   put itemOffset("Visible", kTabs) into tVisibleOffset
   if tVisibleOffset is in the cControlTabs of group "Control Tabs" then
      if tClickH > the left of button "Visible" of group "Control Tabs" and tClickH < the right of button "Visible" of group "Control Tabs" then
         local tNewVis
         put not item tVisibleOffset of line tLine of gREVControls into tNewVis
         put tNewVis into item tVisibleOffset of line tLine of gREVControls
         revSetControlCache gREVControls, the long id of card id (the cCardID of this stack) of stack gREVStackName
         lock screen
         set the visible of tControl to tNewVis
         set the itemDel to tab
         if tNewVis then
            set the imageSource of char 1 of item 2 of line tLine of fld "Controls" to the cTickIcon of this stack
         else
            set the imageSource of char 1 of item 2 of line tLine of fld "Controls" to the cUnTickIcon of this stack
         end if
         unlock screen
         pass mouseUp
      end if
   end if
   
   local tSelectableOffset
   put itemOffset("Selectable", kTabs) into tSelectableOffset
   if tSelectableOffset is in the cControlTabs of group "Control Tabs" then
      if tClickH > the left of button "Selectable" of group "Control Tabs" and tClickH < the right of button "Selectable" of group "Control Tabs" then
         local tNewSelectable
         put not item tSelectableOffset of line tLine of gREVControls into tNewSelectable
         put tNewSelectable into item tSelectableOffset of line tLine of gREVControls
         revSetControlCache gREVControls, the long id of card id (the cCardID of this stack) of stack gREVStackName
         lock screen
         set the cantSelect of tControl to not tNewSelectable
         
         local tItem
         if tVisibleOffset is in the cControlTabs of group "Control Tabs"
         then put 3 into tItem
         else put 2 into tItem
         set the itemDel to tab
         if tNewSelectable then
            set the imageSource of char 1 of item tItem of line tLine of fld "Controls" to the cTickIcon of this stack
         else
            set the imageSource of char 1 of item tItem of line tLine of fld "Controls" to the cUnTickIcon of this stack
         end if
         unlock screen
      end if
   end if
   
   pass mouseUp
end mouseUp

on mouseDoubleUp
  local tObjects
  put revSelControls() into tObjects
  if tObjects is empty then exit mouseDoubleUp
  
  local tAction
  put revShortCutAction("controls") into tAction 
  switch tAction
  case "Property Inspector"
    send "revIDEOpenInspectorForObjects tObjects" to stack revidelibrary
    break
  case "Edit Script"
    repeat for each line l in tObjects
      edit script of l
    end repeat
    break
  end switch
end mouseDoubleUp

on revControlFieldPopup
  global gREVStackName
  
  local tText
  if the num of words in the text of me is 0 or the hilitedLines of me is empty \
      or revFieldMouseLine(the long id of me) is empty then
    put the text of button "No selection control popup" into tText
    if the clipboard is "objects" and the mode of stack gREVStackName is 1
    then put "Paste" into line 1 of tText
    else put "(Paste" into line 1 of tText
    put tText into button "No selection control popup"
    popup button "No selection control popup" at the clickLoc
  else
    put the text of button "Control popup" into tText
    if revCardOpen() then
      put "Cut" & cr & "Copy" & cr & "Paste" & cr & "Clear" into line 4 to 7 of tText
      if the clipboard is "objects" and the mode of stack gREVStackName is 1
      then put "Paste" into line -4 of tText
      else put "(Paste" into line -4 of tText
    else
      put "(Cut" & cr & "(Copy" & cr & "(Paste" & cr & "(Clear" into line 4 to 7 of tText
    end if
    put tText into button "Control popup"    
    popup button "Control popup" at the clickLoc
  end if
end revControlFieldPopup

on selectionChanged
  global gREVControls, gREVStackName
  if the num of words in the text of me = 0 then exit selectionChanged
  if there is not a card id (the cCardID of this stack) of stack gREVStackName then
    lock screen
    revRefreshTree
    unlock screen
    exit selectionChanged
  end if
  
  local tHilitedLines
  put the hilitedLines of me into tHilitedLines
  if tHilitedLines is not empty and revCardOpen() then
    local tDo
    put "select " into tDo
    repeat for each item i in tHilitedLines
      local tID
      put item 9 of line i of gREVControls into tID
      if there is not a control id tID of card id (the cCardID of this stack) of stack gREVStackName then 
        revRefreshControls true, false
        exit selectionChanged
      end if
      put the long id of control id tID of card id (the cCardID of this stack) \
          of stack gREVStackName && " and " after tDo
    end repeat
    delete char -5 to -1 of tDo
    lock screen
    choose the pointer tool
    do tDo
    unlock screen
  else select empty
end selectionChanged

on mouseEnter
  mouseMove
end mouseEnter

on mouseMove
  if "revShowControlTips" is not among the items of the pendingMessages
  then send "revShowControlTips" to me in 500 milliseconds
end mouseMove

on revShowControlTips
   global gREVControls, gREVStackName
   local tLine
   put revFieldMouseLine(the long id of me) into tLine
   
   local tLayer
   put item 4 of line tLine of gREVControls into tLayer
   lock screen
   set the toolTip of me to empty
   if tLayer is not empty then
      # OK-2010-04-19: Tooltips incorrect in edit group mode, use tOwner instead of the card, as with
      # edit group mode, the stack needs to be used instead.
      local tOwner
      if there is a card id (the cCardID of this stack) of stack gREVStackName then
         put revGetOwnerReference(the long id of card id (the cCardID of this stack) of stack gREVStackName) into tOwner
      end if
      
      local tLongID
      if tOwner is not empty and there is a control tLayer of tOwner then 
         put the long id of control tLayer of tOwner into tLongID
         set the tooltip of me to tLongID
      end if
   end if
   unlock screen
end revShowControlTips

on scrollbarDrag
  local tHScroll
  put the hScroll of me into tHScroll
  if the hScroll of group "Control Tabs" is not tHScroll
  then set the hScroll of group "Control Tabs" to tHScroll
end scrollbarDrag

-----------------------------------------------
Scripts for selection by the keyboard
-----------------------------------------------
 
on keyDown pKey
  if lClearTimerID is not empty then cancel lClearTimerID
  put pKey after lTypeText
  put lTypeText into fld "Control Info"
  if "revSelectTyped" is not among the items of the pendingMessages
  then send "revSelectTyped" to me in 500 milliseconds
end keyDown

on revSelectTyped
  if the short name of this card is not "Cards and Controls" then exit revSelectTyped
  
  local tLine
  put 0 into tLine
  
  local tControls
  put the text of me into tControls
  set the itemDel to tab
  repeat for each line l in tControls
    add 1 to tLine
    local tNumChars
    put the num of chars in lTypeText into tNumChars
    if lTypeText is char 1 to tNumChars of word 1 to -1 of item 5 of l then
      set the hilitedLine of fld "Controls" to tLine
      selectionChanged
      exit repeat
    end if
  end repeat
  send "revClearTyped" to me in 1500 milliseconds
  put the result into lClearTimerID
end revSelectTyped

on revClearTyped
  global gREVStackName, gREVControls
  if the short name of this card is not "Cards and Controls" then exit revClearTyped
  
  put empty into lTypeText
  put (the num of lines in gREVControls) && "Controls (" \
      & the num of items in the hilitedLines of me && "selected)" into fld "Control Info"
end revClearTyped

-----------------------------------------------
