script "stack_App_Browser_group_id_1642"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "Card Tabs" (id 1642)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMoving, lTab, lOffsetTabs, lHOffset, lRightTabs, lLastTab, lDontDoSort, lColWidth
constant kTabs="Name,Num,ID,Script Lines,Marked"
constant kExtraTabs="ID,Script Lines,Marked"

on mouseDown pButton
   if the owner of the target is not me then
      exit mouseDown
   end if
   
   if pButton is 3 then 
      unlock cursor
      if the platform is "MacOS" then
         put true into lDontDoSort 
         revCardsPopup
      end if
   else if revIsResizeWidget() then
      put true into lMoving
      put word 1 to -2 of the short name of the target into lTab
      put the cCardTabs of me into tList
      put empty into lOffsetTabs
      put empty into lRightTabs
      repeat for each item i in tList
         put item (i-5) of kTabs into tTab
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
      put revColWidth(the htmltext of fld "Cards" of grp "Cards", \
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
        revLastTabRight(the long id of fld "Cards" of grp "Cards"), the bottom of btn lLastTab of me
    set the right of btn (lLastTab && "Resize") of me to the right of btn lLastTab of me
    set the hScrollBar of fld "Cards" of grp "Cards" to \
        (the formattedWidth of fld "Cards" of grp "Cards" > \
        the width of fld "Cards" of grp "Cards")
    unlock messages
    set the tabStops of fld "Cards" of grp "Cards" to \
        revTabStops(lOffsetTabs, the long id of grp "Card Tabs")
    unlock screen
  end if
end mouseMove

on mouseUp pButton
   if the owner of the target is not me then
      exit mouseUp
   end if
   
  global gREVObjectTree
  
  revWidgetReleased
  
  if the platform is not "MacOS" and pButton is 3 then 
    revCardsPopup
  else
    if lDontDoSort then
      put false into lDontDoSort
    else if not revIsResizeWidget() then
      set the cursor to watch
      put revSelLineID() into tLineID
      
      put itemOffset(the short name of the target, kTabs) + 5 into tTabNum
      set the cHilitedButton["cards"] of stack "revPreferences" to tTabNum
      put comma&"stack,expanded true" into tLineMatch
      switch
      case the cShowAudioClips of stack "revPreferences"
        put comma&"audioclip,expanded" into tEndofCardMatch
        break
      case the cShowVideoClips of stack "revPreferences"
        put comma&"videoclip,expanded" into tEndofCardMatch
        break
      default
        put comma&"stack,expanded" into tEndofCardMatch
        break
      end switch
       
      put 0 into tSkip
      repeat
        put lineOffset(tLineMatch,gREVObjectTree,tSkip) into tLineOffset
        if tLineOffset is 0 then exit repeat
        put tSkip + tLineOffset into tSkip
        put lineOffset(tEndofCardMatch,gREVObjectTree,tSkip) into tEndLine
        if tEndLine is 0 then put the num of lines in gREVObjectTree into tEndLine           
        else put tEndLine - 1 + tSkip into tEndLine
        put line (tSkip + 1) to tEndLine of gREVObjectTree into tCards
        if tTabNum is among the items of "7,8,9"
        then sort lines of tCards numeric by item tTabNum of each
        else sort lines of tCards text by item tTabNum of each
        put tCards into line (tSkip + 1) to tEndLine of gREVObjectTree
      end repeat
      lock screen
      revUpdateTree revTreeHtml(gREVObjectTree), tLineID
      unlock screen
    end if
  end if
end mouseUp

on mouseRelease
   if the owner of the target is not me then
      exit mouseRelease
   end if
   
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
  put the short name of the target into tTarget
  if word -1 of tTarget is not "Resize" then return false
  put the last item of the cCardTabs of me - 5 into tItem
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

setProp cCardTabs pTabs
  global gREVObjectTree
  lock messages
  put 8 into tTabNum
  repeat for each item i in kExtraTabs
    if tTabNum is not among the items of pTabs then
      if there is a btn i of me then delete btn i of me
      if there is a btn (i && "Resize") of me then delete btn (i && "Resize") of me
    end if
    add 1 to tTabNum
  end repeat
  
  put the cCardTabs of me into tOldTabs
  put item (the last item of tOldTabs - 5) of kTabs into tLastOldTab
  if there is a btn tLastOldTab of me then
    set the rect of btn tLastOldTab of me to the topLeft btn tLastOldTab of me, \
        the left of btn tLastOldTab of me + \
        max((the cMinWidth of btn tLastOldTab of me + 6), revColWidth(the htmltext of fld "Cards" of grp "Cards", \
        itemOffset(tLastOldTab,kTabs))), \
        the bottom of btn tLastOldTab of me
  end if
  
  repeat for each item i in pTabs
    put item (i-5) of kTabs into tTab
    if there is not a btn tTab of me then
      clone btn "Name" of me as tTab
      set the toolTip of btn tTab of me to "Click to sort cards by" && toLower(tTab)
      if tTab is "Script Lines" then
        set the showName of btn tTab of me to false
        put "c" & word 1 of tTab & word 2 of tTab & "Icon" into tCustomName
        set the icon of btn tTab of me to the tCustomName of this stack
        set the leftMargin of btn tTab of me to 4
        set the topMargin of btn tTab of me to 7
        set the cMinWidth of btn tTab of me to 25
        set the width of btn tTab of me to 25
      else
        set the leftMargin of btn tTab of me to 6
        put the formattedWidth of btn tTab of me into tWidth
        set the cMinWidth of btn tTab of me to tWidth
        set the width of btn tTab of me to max(50,tWidth + 6)
      end if
      clone btn "Name Resize" of me as (tTab && "Resize")
    end if
  end repeat
   
  put the top of btn "Name" of me into tTop
  put the left of btn "Name" of me into tLeft
  repeat for each item i in pTabs
    put item (i-5) of kTabs into tTab
    set the topLeft of btn tTab of me to tLeft, tTop
    set the topRight of btn (tTab && "Resize") of me to the topRight of btn tTab of me
    add the width of btn tTab of me to tLeft
  end repeat
   
  set the cCardTabs of me to pTabs
  set the cCardTabs of stack "revPreferences" to pTabs
  set the cLastTab of me to tTab
  unlock messages
end cCardTabs

on revCardsPopup
  put btn "Card tabs popup" into tText
  repeat with i = 1 to 3
    if (i+7) is among the items of the cCardTabs of grp "Card Tabs"
    then put "!c" into char 1 to 2 of line i of tText
    else put "!n" into char 1 to 2 of line i of tText
  end repeat
  set the text of btn "Card tabs popup" to tText
  popup btn "Card tabs popup" at the clickLoc
end revCardsPopup
