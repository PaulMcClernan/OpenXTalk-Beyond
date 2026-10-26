script "stack_App_Browser_group_id_3893"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Audioclips" (id 1580) > group "Audioclip Tabs" (id 3893)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMoving, lTab, lOffsetTabs, lHOffset, lRightTabs, lLastTab, lDontDoSort, lColWidth
constant kTabs="Num,Audioclip,ID,Script Lines,Size"
constant kExtraTabs="ID,Script Lines,Size"

on mouseDown pButton
  if pButton is 3 then
    unlock cursor
    if the platform is "MacOS" then
      put true into lDontDoSort 
      revAudioclipsPopup
    end if
  else if revIsResizeWidget() then
    put true into lMoving
    put word 1 to -2 of the short name of the target into lTab
    put the cAudioclipTabs of me into tList
    put empty into lOffsetTabs
    put empty into lRightTabs
    repeat for each item i in tList
      put item i of kTabs into tTab
      put tTab & cr after lOffsetTabs
      if the right of btn tTab of me > the right of btn lTab of me
      then put tTab & cr after lRightTabs    
    end repeat
    delete last char of lOffsetTabs
    delete last char of lRightTabs
    delete last line of lOffsetTabs
    
    put the last line of lRightTabs into lLastTab
    delete the last line of lRightTabs
    
    put the right of btn lTab of me - the mouseH into lHOffset
    put revColWidth(the htmltext of fld "audioclips", \
        itemOffset(lTab,kTabs)) into lColWidth
  end if
end mouseDown

on mouseMove x
  if lMoving then
    lock screen
    lock messages
    put x+lHOffset into tRight
    put max(tRight, lColWidth + the left of btn lTab of me, \
        the cMinWidth of btn lTab of me + the left of btn lTab of me) into tRight
    set the rect of btn lTab of me to the topleft of btn lTab of me, tRight, the bottom of btn lTab of me
    set the right of the target to tRight
    put the right of btn lTab of me into tLeft
    repeat for each line l in lRightTabs
      set the left of btn l of me to tLeft
      set the right of btn (l && "Resize") of me to the right of btn l of me
      add the width of btn l of me to tLeft
    end repeat
    
    set the rect of btn lLastTab of me to tLeft, the top of btn lLastTab of me, \
        revLastTabRight(the long id of fld "Audioclips"), \
        the bottom of btn lLastTab of me
    set the right of btn (lLastTab && "Resize") of me to the right of btn lLastTab of me
    set the hScrollBar of fld "Audioclips" to \
        (the formattedWidth of fld "Audioclips" > \
        the width of fld "Audioclips")
    put the hilitedLines of fld "Audioclips" into tHilitedLines
    unlock messages
    set the tabStops of fld "Audioclips" to \
        revTabStops(lOffsetTabs, the long id of grp "Audioclip Tabs")
    set the hilitedLines of fld "Audioclips" to tHilitedLines
    unlock screen
  end if
end mouseMove

on mouseUp pButton
  global gREVAudioclips
  
  revWidgetReleased
  
  if the platform is not "MacOS" and pButton is 3 then 
    revAudioclipsPopup
  else
    if lDontDoSort then
      put false into lDontDoSort
    else if not revIsResizeWidget() then
      set the cursor to watch
      lock screen
      put revSelAudioIDs(the hilitedLines of fld "Audioclips") into tSelAudioIDs
      put itemOffset(the short name of the target, kTabs) into tTabNum
      set the cHilitedButton["audioclips"] of stack "revPreferences" to tTabNum
      if tTabNum is 4 or (item tTabNum of gREVAudioclips is a number and tTabNum is not 2)
      then sort lines of gREVAudioclips numeric by item tTabNum of each
      else sort lines of gREVAudioclips text by item tTabNum of each
      revUpdateAudioclips true, revAudioOffsets(tSelAudioIDs) 
      unlock screen
    end if
  end if
end mouseUp

on mouseRelease
  revWidgetReleased
end mouseRelease

on mouseDoubleUp
  revWidgetReleased
end mouseDoubleUp

on revWidgetReleased
  put false into lMoving
end revWidgetReleased

function revIsResizeWidget
  put the short name of the target into tTarget
  if word -1 of tTarget is not "Resize" then return false
  put the last item of the cAudioclipTabs of me into tItem
  put item tItem of kTabs into tLastTab
  if tLastTab is word 1 to -2 of tTarget then return false
  return true
end revIsResizeWidget

on mouseEnter
  if revIsResizeWidget() then
    set the cursor to 81
    lock cursor
  end if
end mouseEnter

on mouseLeave
  unlock cursor
end mouseLeave

setProp cAudioclipTabs pTabs
  lock messages
  put 3 into tTabNum
  
  repeat for each item i in kExtraTabs
    if tTabNum is not among the items of pTabs then
      if there is a btn i of me then delete btn i of me
      if there is a btn (i && "Resize") of me 
      then delete btn (i && "Resize") of me
    end if
    add 1 to tTabNum
  end repeat
  
  put the cAudioclipTabs of me into tOldTabs
  put item (the last item of tOldTabs) of kTabs into tLastOldTab
  if there is a btn tLastOldTab of me then
    set the rect of btn tLastOldTab of me to the topLeft btn tLastOldTab of me, \
        the left of btn tLastOldTab of me + \
        max((the cMinWidth of btn tLastOldTab of me + 6), \
        revColWidth(the htmltext of fld "audioclips" of cd "Audioclips", \
        itemOffset(tLastOldTab,kTabs))), \
        the bottom of btn tLastOldTab of me
  end if
  
  repeat for each item i in pTabs
    put item i of kTabs into tTab
    if there is not a btn tTab of me then
      clone btn "Audioclip" of me as tTab
      set the toolTip of btn tTab of me to "Click to sort audioclips by" && toLower(tTab)
      if tTab is "Script Lines" then
        set the showName of btn tTab of me to false
        put "c" & word 1 of tTab & word 2 of tTab & "Icon" into tCustomName
        set the icon of btn tTab of me to the tCustomName of this stack
        set the leftMargin of btn tTab of me to 4
        set the cMinWidth of btn tTab of me to 25
        set the width of btn tTab of me to 25
      else
        set the leftMargin of btn tTab of me to 6
        put the formattedWidth of btn tTab of me into tWidth
        set the cMinWidth of btn tTab of me to tWidth
        set the width of btn tTab of me to max(50,tWidth + 6)
      end if
      clone btn "Audioclip Resize" of me as (tTab && "Resize")
    end if
  end repeat
   
  put the top of btn "Num" of me into tTop
  put the left of btn "Num" of me into tLeft
  repeat for each item i in pTabs
    put item i of kTabs into tTab
    set the topLeft of btn tTab of me to tLeft, tTop
    set the topRight of btn (tTab && "Resize") of me to the topRight of btn tTab of me
    add the width of btn tTab of me to tLeft
  end repeat
   
  set the cAudioclipTabs of me to pTabs
  set the cAudioclipTabs of stack "revPreferences" to pTabs
  set the cLastTab of me to tTab
  unlock messages
end cAudioclipTabs

on revAudioclipsPopup
  put btn "Audioclip tabs popup" into tText
  repeat with i = 1 to 3
    if (i+2) is among the items of the cAudioclipTabs of grp "Audioclip Tabs"
    then put "!c" into char 1 to 2 of line i of tText
    else put "!n" into char 1 to 2 of line i of tText
  end repeat
  set the text of btn "Audioclip tabs popup" to tText
  popup btn "Audioclip tabs popup" at the clickLoc
end revAudioclipsPopup
