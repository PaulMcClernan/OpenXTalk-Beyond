script "stack_App_Browser_group_id_2880"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "Control Tabs" (id 2880)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMoving, lTab, lOffsetTabs, lHOffset, lRightTabs, lLastTab, lDontDoSort, lColWidth
constant kTabs="Type,Visible,Selectable,Layer,Control,ID,Script Lines"
constant kExtraTabs="Visible,Selectable,ID,Script Lines"

on mouseDown pButton
   if the owner of the target is not me then
      exit mouseDown
   end if
   
   if pButton is 3 then
      unlock cursor
      if the platform is "MacOS" then
         put true into lDontDoSort 
         revControlsPopup
      end if
   else if revIsResizeWidget() then
      put true into lMoving
      put word 1 to -2 of the short name of the target into lTab
      
      local tList
      put the cControlTabs of me into tList
      put empty into lOffsetTabs
      put empty into lRightTabs
      repeat for each item i in tList
         local tTab
         put item i of kTabs into tTab
         put tTab & cr after lOffsetTabs
         if the right of button tTab of me > the right of button lTab of me
         then put tTab & cr after lRightTabs    
      end repeat
      delete last char of lOffsetTabs
      delete last char of lRightTabs
      delete last line of lOffsetTabs
      
      put the last line of lRightTabs into lLastTab
      delete the last line of lRightTabs
      
      put the right of button lTab of me - the mouseH into lHOffset
      put revColWidth(the htmltext of fld "Controls", \
            itemOffset(lTab,kTabs)) into lColWidth
      
   end if
end mouseDown

on mouseMove x
   if the owner of the target is not me then
      exit mouseMove
   end if
   
  if lMoving then
    lock screen
    lock messages
    
    local tRight
    put x+lHOffset into tRight
    put max(tRight, lColWidth + the left of button lTab of me, \
        the cMinWidth of button lTab of me + the left of button lTab of me) into tRight
    set the rect of button lTab of me to the topleft of button lTab of me, tRight, the bottom of button lTab of me
    set the right of the target to tRight
    
    local tLeft
    put the right of button lTab of me into tLeft
    repeat for each line l in lRightTabs
      set the left of button l of me to tLeft
      set the right of button (l && "Resize") of me to the right of button l of me
      add the width of button l of me to tLeft
    end repeat
    
    set the rect of button lLastTab of me to tLeft, the top of button lLastTab of me, \
        revLastTabRight(the long id of fld "Controls"), \
        the bottom of button lLastTab of me
    set the right of button (lLastTab && "Resize") of me to the right of button lLastTab of me
    set the hScrollBar of fld "Controls" to \
        (the formattedWidth of fld "Controls" > \
        the width of fld "Controls")
     
    local tHilitedLines
    put the hilitedLines of fld "Controls" into tHilitedLines
    unlock messages
    set the tabStops of fld "Controls" to \
        revTabStops(lOffsetTabs, the long id of grp "Control Tabs")
    set the hilitedLines of fld "Controls" to tHilitedLines
    unlock screen
  end if
end mouseMove

on mouseUp pButton
   if the owner of the target is not me then
      exit mouseUp
   end if
   
  global gREVControls, gREVStackName
  
  revWidgetReleased
  
  if the platform is not "MacOS" and pButton is 3 then 
    revControlsPopup
  else
    if lDontDoSort then
      put false into lDontDoSort
    else if not revIsResizeWidget() then
      set the cursor to watch
      
      local tTabNum
      put itemOffset(the short name of the target, kTabs) into tTabNum
      set the cHilitedButton["controls"] of stack "revPreferences" to tTabNum
      if tTabNum is itemOffset("Script Lines", kTabs) or \
          (item tTabNum of gREVControls is a number and tTabNum is not itemOffset("Control", kTabs))
      then sort lines of gREVControls numeric by item tTabNum of each
      else sort lines of gREVControls text by item tTabNum of each
      revSetControlCache gREVControls, the long id of card id (the cCardID of this stack) of stack gREVStackName
      lock screen
      revUpdateControlsField true
      unlock screen
    end if
  end if
end mouseUp

on mouseRelease
  revWidgetReleased
end mouseRelease

on mouseDoubleUp
   if the owner of the target is not me then
      exit mouseDoubleUp
   end if
   
  revWidgetReleased
end mouseDoubleUp

on revWidgetReleased
  put false into lMoving
end revWidgetReleased

function revIsResizeWidget
  local tTarget
  put the short name of the target into tTarget
  if word -1 of tTarget is not "Resize" then return false
  
  local tItem
  put the last item of the cControlTabs of me into tItem
  
  local tLastTab
  put item tItem of kTabs into tLastTab
  if tLastTab is word 1 to -2 of tTarget then return false
  return true
end revIsResizeWidget

on mouseEnter
   if the owner of the target is not me then
      exit mouseEnter
   end if
   
  if revIsResizeWidget() then
    set the cursor to 81
    lock cursor
  end if
end mouseEnter

on mouseLeave
   if the owner of the target is not me then
      exit mouseLeave
   end if
   
  unlock cursor
end mouseLeave

setProp cControlTabs pTabs
  lock messages
  repeat for each item i in kExtraTabs
    if itemOffset(i,kTabs) is not among the items of pTabs then
      if there is a button i of me then delete button i of me
      if there is a button (i && "Resize") of me 
      then delete button (i && "Resize") of me
    end if
  end repeat
  
  local tOldTabs
  put the cControlTabs of me into tOldTabs
  
  local tLastOldTab
  put item (the last item of tOldTabs) of kTabs into tLastOldTab
  if there is a button tLastOldTab of me then
    set the rect of button tLastOldTab of me to the topLeft button tLastOldTab of me, \
        the left of button tLastOldTab of me + \
        max((the cMinWidth of button tLastOldTab of me + 6), \
        revColWidth(the htmltext of fld "Controls" of cd "Cards and Controls", \
        itemOffset(tLastOldTab,kTabs))), \
        the bottom of button tLastOldTab of me
  end if
  
  repeat for each item i in pTabs
    local tTab
    put item i of kTabs into tTab
    if there is not a button tTab of me then
      clone button "Control" of me as tTab
      set the toolTip of button tTab of me to "Click to sort controls by" && toLower(tTab)
      if tTab is among the items of "Visible,Selectable,Script Lines" then
        set the showName of button tTab of me to false
        
        local tCustomName
        put "c" & word 1 of tTab & word 2 of tTab & "Icon" into tCustomName
        set the icon of button tTab of me to the tCustomName of this stack
        set the leftMargin of button tTab of me to 4
        set the topMargin of button tTab of me to 7
        set the cMinWidth of button tTab of me to 25
        set the width of button tTab of me to 25
      else
        set the leftMargin of button tTab of me to 6
        
        local tWidth
        put the formattedWidth of button tTab of me into tWidth
        set the cMinWidth of button tTab of me to tWidth
        set the width of button tTab of me to max(50,tWidth + 6)
      end if
      clone button "Control Resize" of me as (tTab && "Resize")
    end if
  end repeat
  
  local tTop
  put the top of button "Type" of me into tTop
  
  local tLeft
  put the left of button "Type" of me into tLeft
  repeat for each item i in pTabs
    put item i of kTabs into tTab
    set the topLeft of button tTab of me to tLeft, tTop
    set the topRight of button (tTab && "Resize") of me to the topRight of button tTab of me
    add the width of button tTab of me to tLeft
  end repeat
  
  set the cControlTabs of me to pTabs
  set the cControlTabs of stack "revPreferences" to pTabs
  set the cLastTab of me to tTab
  unlock messages
end cControlTabs

on revControlsPopup
  local tText
  put button "control tabs popup" into tText
  
  local tCount
  put 0 into tCount
   
  repeat for each item i in kExtraTabs
    add 1 to tCount
    if itemOffset(i,kTabs) is among the items of the cControlTabs of grp "Control Tabs"
    then put "!c" into char 1 to 2 of line tCount of tText
    else put "!n" into char 1 to 2 of line tCount of tText
  end repeat
  set the text of button "control tabs popup" to tText
  popup button "control tabs popup" at the clickLoc
end revControlsPopup
