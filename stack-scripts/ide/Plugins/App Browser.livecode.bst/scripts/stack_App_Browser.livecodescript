script "stack_App_Browser"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kComma="######REVCOMMA#####", kTab="&#9;", kTag="#####REVLESSTHANCHARACTER#####"
constant kTabs="Name,Num,ID,Script Lines,Marked", kLessThan="['less than' character]"
constant kControlTabs="Type,Visible,Selectable,Layer,Control,ID,Script Lines"
local lMainStackIcon, lSubStackIcon, lVideoClipIcon, lAudioClipIcon, lInIcon, lOutIcon
local lCurrentStacks, lInitialised, lControlCache, lCardCache

on preOpenStack
   
   global gREVStackName
   revIDESubscribe "ideSelectedObjectChanged"
   lock screen
   
   --set the title of this stack to "Application Browser"--workaround engine bug
   
   if not lInitialised then
      set the textFont of field "Cards" of group "Cards" to empty
      set the textFont of field "Controls" of card "Cards and Controls" to empty
      set the textFont of field "AudioClips" of card "Audioclips" to empty
      set the textFont of field "Videoclips" of card "Videoclips" to empty
      
      set the textHeight of field "Cards" of group "Cards" to 22
      set the textHeight of field "Controls" of card "Cards and Controls" to 22
      set the textHeight of field "AudioClips" of card "Audioclips" to 22
      set the textHeight of field "Videoclips" of card "Videoclips" to 22
      
      set the hiliteColor of this stack to empty
      
      put the cMainStackIcon of this stack into lMainStackIcon
      put the cSubstackIcon of this stack into lSubstackIcon
      put the cVideoclipIcon of this stack into lVideoClipIcon
      put the cAudioclipIcon of this stack into lAudioClipIcon
      if the platform is "MacOS" then
         if char 1 of the systemVersion is 1 then
            put the cOSXInIcon of this stack into lInIcon
            put the cOSXOutIcon of this stack into lOutIcon
         else
            put the cClassicInIcon of this stack into lInIcon
            put the cClassicOutIcon of this stack into lOutIcon
         end if
      else
         put the cWindowsInIcon of this stack into lInIcon
         put the cWindowsOutIcon of this stack into lOutIcon
      end if
      put true into lInitialised
   end if
   
   tTPLinkColours -- (tperry) -- corrects the link colours based on whatever the background colour of the window is
   
   set the cAppOverview of stack "revPreferences" to true
   revInitAppBrowser
   put empty into gREVStackName
   set the cCardID of this stack to empty
   put empty into field "Card Info"
   
   # OK-2007-09-17: Bug 5400, refresh button is not visible on application browser init.
   revUpdateGeometry
   unlock screen
   pass preOpenStack
end preOpenStack

on ideSelectedObjectChanged
   revUpdatePalette
   
   -- tperry 28-11-23 (added this behaviour for my Properties Inspector)
   if there is a window "Properties Inspector" then
      if there is a fld "tObj" of cd 1 of wd "Properties Inspector" then
         -- if not (the pendingmessages contains "tGetSelectedObj") then send tGetSelectedObj to stack "Properties Inspector"
      end if
   end if 
   
end ideSelectedObjectChanged

-- This is here to fix bug 6735 - basically it wraps the revCommon call, but ensures 
private function filterStacksList pStacks
   return revFilterStacksList(pStacks)
end filterStacksList

on closeStackRequest
  --  revRetainStacks
  --  set the cAppOverview of stack "revPreferences" to false
  revAppBrowserFinalise
  pass closeStackRequest
end closeStackRequest

# OK-2007-06-29: Bug 4958
command revAppBrowserFinalise
  revRetainStacks
  set the cAppOverview of stack "revPreferences" to false
end revAppBrowserFinalise

on revRefreshTree
  global gREVObjectTree
  
  revRetainStacks
  
  local tLineID
  put revSelLineID() into tLineID
  revGenerateTree lCurrentStacks
  revUpdateTree revTreeHtml(gREVObjectTree), tLineID
  if tLineID is not empty then
    
    local tLineOffset
    put lineOffset(tLineID,gREVObjectTree) into tLineOffset
    if tLineOffset is not 0 
    then send "revSelectTree tLineOffset" to field "Cards" of group "Cards"
    else set the currentCard of this stack to "Blank"
  else set the currentCard of this stack to "Blank"
end revRefreshTree

on revInitAppBrowser
  global gREVObjectTree
  set the cursor to watch
  lock messages
  set the rect of this stack to the cAppBrowserRect of stack "revPreferences"
  revInternal__ConstrainStack "App Browser"
  unlock messages
  
  set the cCardTabs of group "Card Tabs" of card "Cards and Controls" to  the cCardTabs of stack "revPreferences"
  set the cControlTabs of group "Control Tabs" of card "Cards and Controls" to  the cControlTabs of stack "revPreferences"
  set the cAudioclipTabs of group "Audioclip Tabs" of card "Audioclips" to the cAudioclipTabs of stack "revPreferences"
  set the cVideoclipTabs of group "Videoclip Tabs" of card "Videoclips" to the cVideoclipTabs of stack "revPreferences"
  
  set the currentCard of this stack to "Blank"
  send "revResizeWidget" && the cAppBrowserWidgetLeft of stack "revPreferences" to button "Resize" of card "Blank"
   
  local tTopStack
  put revBrowserTopStack() into tTopStack
  
  local tExpandedStacks
  if lCurrentStacks is empty then put tTopStack into tExpandedStacks
  else put lCurrentStacks & return & tTopStack into tExpandedStacks
  revGenerateTree tExpandedStacks
  
  local tVScroll, tHScroll
  put the vScroll of field "Cards" of group "Cards" into tVScroll
  put the hScroll of field "Cards" of group "Cards" into tHScroll
  revSetTreeHtml revTreeHtml(gREVObjectTree)
  set the vScroll of field "Cards" of group "Cards" to tVScroll
  set the hScroll of field "Cards" of group "Cards" to tHScroll
  set the hScroll of group "Card Tabs" to tHScroll
end revInitAppBrowser

on revGenerateTree pExpandedStacks
  global gREVObjectTree, gREVShowStacks
  
  local tMainStacks
  put the mainStacks into tMainStacks
  
  # TH-2008-07-15 :: Bug 6735 this replaces a call in preopenstack to revfilterstackslist
  if not gREVShowStacks then put filterStacksList(tMainStacks) into tMainStacks
  --if not gREVShowStacks then put revFilterStacksList(tMainStacks) into tMainStacks
  
  sort tMainStacks  
  local tStacks
  put empty into tStacks
  repeat for each line l in tMainStacks
    put l & return after tStacks
    
    local tSubStacks
    put the substacks of stack l into tSubstacks
    sort lines of tSubstacks
    if tSubstacks is not empty then put tSubstacks & return after tStacks
  end repeat
  
  put empty into gREVObjectTree
  repeat for each line l in tStacks
    
    local tLine
    put revStackLine(l) into tLine
    if l is among the lines of pExpandedStacks then
      put "expanded true" && lOutIcon into item 3 of tLine
      if the editBg of stack l then set the editBg of stack l to false--so all cards listed
      put return & revCardList(the cardIDS of stack l,l) after tLine
      if the cShowAudioClips of stack "revPreferences"
      then put return & revAudioClipLine(l) after tLine
      if the cShowVideoClips of stack "revPreferences"
      then put return & revVideoClipLine(l) after tLine
    end if
    put tLine & return after gREVObjectTree
  end repeat
  delete last char of gREVObjectTree
end revGenerateTree

function revStackLine pStack
  if the mainStack of stack pStack is pStack then
    
    local tIcon
    put lMainStackIcon into tIcon
    
    local tSpace
    put empty into tSpace
  else
    put lSubstackIcon into tIcon
    put space & space into tSpace
  end if
  
  local tName
  put pStack into tName
  replace comma with kComma in tName
  try
    local tScriptLines
    put the num of lines in the script of stack pStack into tScriptLines
  catch tError
    put "unknown" into tScriptLines
  end try
  
  local tLine
  put tName,"stack","expanded false" && lInIcon,tSpace,tIcon,tName & comma & comma & comma & tScriptLines & comma & comma & comma & comma & comma & tName into tLine
  return tLine  
end revStackLine

function revAudioClipLine pStack
  replace comma with kComma in pStack
  return pStack,"audioclip","expanded false",space&space&space&space&space&space&space&space,\
      lAudioClipIcon,"AudioClips" &comma&comma&comma&comma&comma&comma&comma&comma&pStack
end revAudioClipLine

function revVideoClipLine pStack
  replace comma with kComma in pStack
  return pStack,"videoclip","expanded false",space&space&space&space&space&space&space&space,\
      lVideoClipIcon,"VideoClips" &comma&comma&comma&comma&comma&comma&comma&comma&pStack
end revVideoClipLine

on revUpdateTree pHtml, pSelLineID
  local tVScroll, tHScroll
  put the vScroll of field "Cards" of group "Cards" into tVScroll
  put the hScroll of field "Cards" of group "Cards" into tHScroll
  
  local tTabs
  put 0,0,0,0,0,kTabs into tTabs
  revSetHtml the long id of field "Cards" of group "Cards", pHtml, tTabs, \
      the long id of group "Card Tabs", the cCardTabs of stack "revPreferences", \
      the left of button "Name" of group "Card Tabs"
  set the cSelLine of field "Cards" of group "Cards" to empty
  
  revReselectLine pSelLineID
  set the vScroll of field "Cards" of group "Cards" to tVScroll
  set the hScroll of field "Cards" of group "Cards" to tHScroll
end revUpdateTree

on revSetTreeHtml pHtml
  local tTabs
  put 0,0,0,0,0,kTabs into tTabs
  revSetHtml the long id of field "Cards" of group "Cards", pHtml, tTabs, \
      the long id of group "Card Tabs", the cCardTabs of stack "revPreferences", \
      the left of button "Name" of group "Card Tabs"
  set the cSelLine of field "Cards" of group "Cards" to empty
end revSetTreeHtml

on revSetHtml pField, pHtml, pTabs, pTabGroup, pGroupTabs, pStartLeft
  if pHtml is empty then
    --enter appropriate num of tabs so that field scrollable
    
    local tNumTabs
    put the num of items in the tabStops of pField into tNumTabs
    put "<p>" into pHtml
    repeat tNumTabs
      put space & kTab after pHtml
    end repeat
    put "</p>" after pHtml
  end if
   
  --be sure 'formattedWidth' of column big enough
  local tLastItem
  put the last item of pGroupTabs into tLastItem
  
  local tName
  put item tLastItem of pTabs into tName
  
  local tWidth
  put the cMinWidth of button tName of pTabGroup into tWidth
   
   
  local tCharMin
  put max(round(tWidth/2.6),16) into tCharMin
  
  local tLastLine
  put the last line of pHtml into tLastLine
  
  local tSkip
  put 0 into tSkip
  
  local tTabChar
  if kTab is in pHtml then put kTab into tTabChar
  else put tab into tTabChar
  
  local tOffset
  repeat
    put offset(tTabChar, tLastLine, tSkip) into tOffset
    if tOffset is 0 then exit repeat
    else add tOffset to tSkip
  end repeat
   
  local tNumChars
  put the num of chars in char tSkip to -1 of tLastLine into tNumChars
  
  if tNumChars <= tCharMin then
    local tRepeat
    put tCharMin - tNumChars into tRepeat
    
    local tSpaces
    put empty into tSpaces
    repeat tRepeat
      put space after tSpaces
    end repeat
    put tSpaces before char -4 of pHtml
  end if
  set the htmlText of pField to pHtml
  revSetVScrollbar pField, pTabGroup
   
  local tHtml
  put pHtml into tHtml
  replace kTab with tab in tHtml
  set the itemDel to tab
  repeat for each line l in tHtml
    local tCount
    put 0 into tCount
    local tColumn
    repeat for each item i in l
      add 1 to tCount
      put "<p>"&i&"</p>" & return after tColumn[tCount]
    end repeat
  end repeat
  set the itemDel to comma
  
  put 0 into tCount
  
  local tLeft
  put pStartLeft into tLeft
  
  local tTabs
  put empty into tTabs
  repeat for each item i in pGroupTabs
    add 1 to tCount
    
    local tTab
    put item i of pTabs into tTab
    put tTab & return after tTabs
    set the htmlText of field "measure width" to tColumn[tCount]
    put max(the width of button tTab of pTabGroup, \
        (the formattedWidth of field "measure width" + 2)) into tWidth
     
    local tRight
    put tLeft + tWidth into tRight
    set the rect of button tTab of pTabGroup to tLeft, the top of button tTab of pTabGroup, \
        tRight, the bottom of button tTab of pTabGroup
    set the right of button (tTab && "Resize") of pTabGroup to tRight
    put tRight into tLeft
  end repeat
  delete last char of tTabs
  
  set the rect of button tTab of pTabGroup to the topLeft of button tTab of pTabGroup, \
      revLastTabRight(pField), the bottom of button tTab of pTabGroup
  delete last line of tTabs
  set the tabStops of pField to revTabStops(tTabs, pTabGroup)
  set the hScrollBar of pField to \
      (the formattedWidth of pField > the width of pField)
  if not the hScrollBar of pField then set the hScroll of pTabGroup to 0
end revSetHtml

# OK-2007-11-23 : Modified to allow tab groups to cover area above field scrollbars.
# Note that this function despite the name does not just change the vscrollbar value...
on revSetVScrollbar pField, pTabGroup
  if the formattedHeight of pField > the height of pField then
    set the vScrollBar of pField to true
    set the rect of pTabGroup to the topLeft of pTabGroup, the right of pField - 1, the bottom of pTabGroup
  else
    set the vScrollBar of pField to false
    set the rect of pTabGroup to the topLeft of pTabGroup, the right of pField, the bottom of pTabGroup
  end if
end revSetVScrollbar

on revResizeBrowser
  revSetVScrollbar the long id of field "Cards" of group "Cards",  the long id of group "Card Tabs"
  set the cAppBrowserRect of stack "revPreferences" to the rect of this stack
end revResizeBrowser

on resizeStack
   revUpdateGeometry
   revResizeBrowser
   
   if there is a button "Refresh" of this card of me then
      set the bottom of button "Refresh" of this card of me to the bottom of this card of me
      set the right of button "Refresh" of this card of me to the right of field "Cards" of this card of me
   end if
   if there is a group "control Tabs" of this card then
      if there is a fld "controls" of this card then
         set the left of group "control Tabs" of this card to (the left of fld "controls" of this card) +11
      end if
   end if
   if there is a button "Resize" of this card then
      set the hilite of button "Resize" of this card to false
   end if
end resizeStack

on moveStack
  set the cAppBrowserRect of stack "revPreferences" to the rect of this stack
end moveStack

function revTreeHtml pSource
  local tCardTabs
  put the cCardTabs of stack "revPreferences" into tCardTabs
  
  local tTickIcon
  put the cTickIcon of this stack into tTickIcon
  
  local tUnTickIcon
  put the cUnTickIcon of this stack into tUnTickIcon
  
  local tSuperScriptIcon
  if the platform is "MacOS" then put false into tSuperScriptIcon
  else put true into tSuperScriptIcon
  
  local tHtml
  put empty into tHtml
  repeat for each line l in pSource
    put kTag & "p>" after tHtml
    put item 4 of l after tHtml#spacing
    if word 3 of item 3 of l is not empty then
      if tSuperScriptIcon
      then put kTag&"sup>"&kTag&"img src="&quote&word 3 of item 3 of l&quote&">"&kTag&"/sup>" after tHtml
      else put kTag & "img src="&quote&word 3 of item 3 of l&quote&">" after tHtml#triangle icon
    end if
    put space & space & kTag & "img src="&quote&item 5 of l&quote&"> " after tHtml#object type icon
    local tItem
    repeat for each item i in tCardTabs
      put item i of l into tItem
      switch i
      case 6
        put kTag & "a>"&tItem&kTag&"/a>" & kTab after tHtml#group name
        break
      case 10
        switch tItem
        case true
          put kTag & "img src="&quote&tTickIcon&quote&">" & kTab after tHtml
          break
        case false
          put kTag & "img src="&quote&tUnTickIcon&quote&">" & kTab after tHtml
          break
        default
          put kTab after tHtml
        end switch
        break
      case 9
        if tItem is "unknown"
        then put kTag & "img src="&quote&the cPasswordIcon of this stack&quote&">" & kTab after tHtml
        else put tItem & kTab after tHtml
        break
      default
        put tItem & kTab after tHtml
        break
      end switch
    end repeat
    delete char -4 to -1 of tHtml
    put kTag & "/p>" & return after tHtml
  end repeat
  delete last char of tHtml
  replace "<" with kLessThan in tHtml--user friendly message, "<" breaks html
  replace kTag with "<" in tHtml
  replace tab with space&space in tHtml
  replace kComma with comma in tHtml
  return tHtml
end revTreeHtml

function revCardList pCardIDs, pStack, pUseCache
  local tCardIcon
  put the cCardIcon of this stack into tCardIcon
  set the defaultStack to pStack
  replace comma with kComma in pStack
  
  local tCards
  put empty into tCards
  
  local tName, tScriptLines
  repeat for each line l in pCardIDs
    put the short name of card id l into tName
    replace comma with kComma in tName
    try
      put the num of lines in the script of card id l into tScriptLines
    catch tError
      put "unknown" into tScriptLines
    end try
    
    put pStack,"card","expanded false" & comma \
        & space & space & space & space & space & space & space & space & space & space & comma \
        & tCardIcon,tName,the num of card id l,\
    l,tScriptLines,the mark of card id l,\
    "#####REVID=", l, "=#####REVID",pStack & return after tCards
  end repeat
  delete last char of tCards
  set the defaultStack to "App Browser"
  
  local tTabNum
  put the cHilitedButton["cards"] of stack "revPreferences" into tTabNum
  if tTabNum is among the items of "7,8,9"
  then sort lines of tCards numeric by item tTabNum of each
  else sort lines of tCards text by item tTabNum of each
  put tCards into lCardCache
  return tCards
end revCardList

on revRefreshControls pSaveScroll, pUseCache
  global gREVStackName, gREVControls
  lock screen
  if the short name of this card is not "Cards and Controls" then exit revRefreshControls
  if gREVStackName is empty then
    put empty into gREVControls
    put empty into field "Controls"
    put empty into field "Control Info"    
  else
    if the num of controls in card id (the cCardID of this stack) of stack gREVStackName > 49
    then set the cursor to watch
    put revControlList(the long id of card id (the cCardID of this stack)\
        of stack gREVStackName, pUseCache) into gREVControls
    revUpdateControlsField pSaveScroll
  end if
  unlock screen
end revRefreshControls

on revUpdateControlsField pSaveScroll
  global gREVControls
  local tHScroll, tVScroll
  put the hScroll of field "Controls" into tHScroll
  put the vScroll of field "Controls" into tVScroll
  
  local tHtml
  put revControlsHtml(gREVControls) into tHtml
  revSetHtml the long id of field "Controls" of card "Cards and Controls", tHtml, \
      kControlTabs, the long id of group "Control Tabs", the cControlTabs of stack "revPreferences", \
      the left of button "Type" of group "Control Tabs"
  revUpdatePalette
  set the hScroll of field "Controls" to tHScroll
  if pSaveScroll then set the vScroll of field "Controls" to tVScroll
end revUpdateControlsField
  
function revCardOffset pLongID
  global gREVObjectTree
  if word 1 of pLongID is not "card" then return 0
  local tStack
  put the short name of the owner of pLongID into tStack
  replace comma with kComma in tStack
  
  local tCardLine
  put "#####REVID=",word 3 of pLongID,"=#####REVID",tStack into tCardLine
  return lineOffset(tCardLine,gREVObjectTree)
end revCardOffset

function revStackOffset pStack
  global gREVObjectTree
  replace comma with kComma in pStack
  
  local tStackLine
  put pStack,"stack,expanded" into tStackLine
  return lineOffset(tStackLine,gREVObjectTree)
end revStackOffset

# OK-2010-04-19: Bug 8734
# This function returns a reference to either the card or stack,
# depending on whether or not we're in edit group mode. This reference should be used
# as the owner of controls on the current card to let edit group mode work properly.
function revGetOwnerReference pCard
   local tStack
   put revTargetStack(pCard) into tStack
   if the editbackground of stack tStack then
      return the long id of stack tStack
   else
      return pCard
   end if
end revGetOwnerReference

function revControlList pCard, pUseCache
   local tStack
   put revTargetStack(pCard) into tStack
   
   # OK-2010-04-19: Bug 8734 - If we're in edit group mode, there is a temporary card created on the stack
   # which appears to be given the same id and name as the current card. This means we can't easily list its
   # controls. Luckily however, we can list the controls of the stack instead and get the same result. There seem
   # to be numerous other problems with edit group mode and the application browser...
   local tObject
   put revGetOwnerReference(pCard) into tObject
   
   local tNumControls
   put the num of controls in tObject into tNumControls
   
   -- its done already, save performance
   if the number of lines in lControlCache[pCard] is tNumControls and pUseCache
   then return lControlCache[pCard]
   
   local tHCAddressing
   put the hcAddressing of stack tStack into tHCAddressing
   set the hcAddressing of stack tStack to false
   
   local tControls, tName, tScriptLines, tSGCGroup, tSGCGroupChar
   put empty into tControls
   put false into tSGCGroup
   put 1 into tSGCGroupChar
   repeat with i = 1 to tNumControls
      put the short name of control i of tObject into tName
      replace comma with kComma in tName
      try
         put the num of lines in the script of control i of tObject into tScriptLines
      catch tError
         put "unknown" into tScriptLines
      end try
      
      local tGroupExp
      put word 2 to -1 of the long id of control i of tObject into tGroupExp
      
      local tIndentedName
      put tName into tIndentedName
      
      local tGroupNestCount
      put 0 into tGroupNestCount
      repeat for each word w in tGroupExp
         if w is "group" then put space&&space before tIndentedName
      end repeat
      
      if char tSGCGroupChar of tIndentedName is not space then
         put false into tSGCGroup
      end if
      
      if not tSGCGroup then
         put word 1 of the name of control i of tObject, the visible of control i of tObject, \
                not the cantSelect of control i of tObject, the layer of control i of tObject, \
                tName, the id of control i of tObject, tScriptLines, \
                "#####REVID=", the id of control i of tObject, \
                "=#####REVID", tIndentedName & return after tControls
      end if
      
      # MW-2011-05-24: [[ Bug 9527 ]] Integrate fix from TKD
      ## only perform check if tSGCGroup is false. Once selectedGroupedControls
      ## is turned of it stays off for all controls nested within the group.
      if not tSGCGroup and word 1 of the name of control i of tObject is "group" and the selectGroupedControls of control i of tObject is false then
         put true into tSGCGroup
         repeat with x = 1 to the number of chars in tIndentedName
            if char x of tIndentedName is not space then exit repeat
         end repeat
         put x into tSGCGroupChar
      end if
      
   end repeat
   
   delete last char of tControls
   set the hcAddressing of stack tStack to tHCAddressing
   
   local tTabNum
   put the cHilitedButton["controls"] of stack "revPreferences" into tTabNum
   if tTabNum is 7 or (item tTabNum of tControls is a number and tTabNum is not 5)
   then sort lines of tControls numeric by item tTabNum of each
   else sort lines of tControls text by item tTabNum of each
   
   put tControls into lControlCache[pCard]
   
   return tControls
end revControlList

on revClearControlCache pTarget
  set the wholeMatches to true
  
  local tOffset
  put wordOffset("card", pTarget) into tOffset
  
  local tID
  put word (tOffset + 2) of pTarget into tID
  if there is a card id tID then -- km patched this
    local tCard
    put the long id of card id tID of stack revTargetStack(pTarget) into tCard
    put empty into lControlCache[tCard]  
  end if
end revClearControlCache

on revSetControlCache pControls, pCard
  put pControls into lControlCache[pCard]
end revSetControlCache
  
function revControlsHtml pControls
  --generate html with embedded icons for speed
  local tControlsHtml
  put empty into tControlsHtml
  
  local tControlTabs
  put the cControlTabs of stack "revPreferences" into tControlTabs
  if item 1 of tControlTabs is 1 then delete item 1 of tControlTabs
  
  local tTickIcon
  put the cTickIcon of this stack into tTickIcon
  
  local tUnTickIcon
  put the cUnTickIcon of this stack into tUnTickIcon
  
  local tLayerOffset
  put itemOffset("Layer", kControlTabs) into tLayerOffset
  
  local tControlOffset
  put itemOffset("Control", kControlTabs) into tControlOffset
  
  local tVisibleOffset
  put itemOffset("Visible", kControlTabs) into tVisibleOffset
  
  local tSelectableOffset
  put itemOffset("Selectable", kControlTabs) into tSelectableOffset
  
  local tScriptLinesOffset
  put itemOffset("Script Lines", kControlTabs) into tScriptLinesOffset
  repeat for each line l in pControls
    
    local tIconProp
    put "c"&item 1 of l&"Icon" into tIconProp
    
    local tIcon
    put the tIconProp of this stack into tIcon
    put kTag & "p>" & kTag & "img src="&quote&tIcon&quote&">" after tControlsHtml
    repeat for each item i in tControlTabs
      local tItem
      put item i of l into tItem
      switch i
      case tControlOffset
        --indent grouped controls if sorted by layer
        if the cHilitedButton["controls"] of stack "revPreferences" is tLayerOffset
        then put kTab & item 11 of l after tControlsHtml
        else put kTab & tItem after tControlsHtml
        break
      case tVisibleOffset
      case tSelectableOffset
        if tItem then put kTab & kTag & "img src="&quote&tTickIcon&quote&">" after tControlsHtml
        else put kTab & kTag & "img src="&quote&tUnTickIcon&quote&">" after tControlsHtml
        break
      case tScriptLinesOffset
        if tItem is "unknown"
        then put kTab & kTag & "img src="&quote&the cPasswordIcon of this stack &quote&">" after tControlsHtml
        else put kTab & tItem after tControlsHtml
        break
      default
        put kTab & tItem after tControlsHtml
        break
      end switch
    end repeat
    put kTag & "/p>" & return after tControlsHtml
  end repeat
  delete last char of tControlsHtml
  replace tab with space&space in tControlsHtml
  replace kComma with comma in tControlsHtml
  replace "<" with kLessThan in tControlsHtml--user friendly message, "<" breaks html
  replace kTag with "<" in tControlsHtml
  return tControlsHtml
end revControlsHtml

function revControlLine pID, pControls
  local tLine
  put "#####REVID=", pID, "=#####REVID" into tLine
  return lineOffset(tLine, pControls)
end revControlLine

function revInIcon
  return lInIcon
end revInIcon

function revOutIcon
  return lOutIcon
end revOutIcon

function revTabStops pTabs, pGroup
  local tLeft
  put the left of pGroup into tLeft
  
  local tTabStops
  put empty into tTabStops
  repeat for each line l in pTabs
    put the right of button l of pGroup - tLeft - 2 + the hScroll of pGroup & comma after tTabStops
  end repeat
  delete last char of tTabStops
  return tTabStops
end revTabStops

function revColWidth pHtml, pColumnNo
  replace kTab with tab in pHtml
  set the itemDel to tab
  repeat for each line l in pHtml
    local tColumn
    put "<p>"&item pColumnNo of l &"</p>" & return after tColumn
  end repeat
  set the htmlText of field "measure width" to tColumn
  return the formattedWidth of field "measure width" + 2
end revColWidth
 
on revMainStackChanged pStack
  global gREVObjectTree
  local tName
  put the short name of pStack into tName
  
  local tStackMatch
  put tName,"stack,expanded" into tStackMatch
  
  local tStartLine
  put lineOffset(tStackMatch,gREVObjectTree) into tStartLine
  if tStartLine is 0 then exit revMainStackChanged
  
  local tEndLine
  put lineOffset((comma&"stack,expanded"),gREVObjectTree,tStartLine) + tStartLine - 1 into tEndLine
  if tEndLine < tStartLine then put the num of lines in gREVObjectTree into tEndLine
  
  local tMain
  put the mainStack of stack tName into tMain
  
  local tStackLines
  put line tStartLine to tEndLine of gREVObjectTree into tStackLines
  delete line tStartLine to tEndLine of gREVObjectTree      
  if tMain is tName then
    put lMainStackIcon into item 5 of line 1 of tStackLines
    put empty into item 4 of line 1 of tStackLines
    put return & tStackLines after gREVObjectTree
  else
    put lSubstackIcon into item 5 of line 1 of tStackLines
    put space & space into item 4 of line 1 of tStackLines
    put tMain,"stack,expanded" into tStackMatch
    
    local tMainLine
    put lineOffset(tStackMatch,gREVObjectTree) into tMainLine
    if tMainLine is 0 then exit revMainStackChanged
    
    local tListBelow
    put line (tMainLine + 1) to -1 of gREVObjectTree into tListBelow
    
    local tCount
    put (tMainLine + 1) into tCount
    
    local tFoundEnd
    put false into tFoundEnd
    repeat for each line l in tListBelow
      add 1 to tCount
      if item 5 of l is lMainStackIcon then 
        put true into tFoundEnd
        exit repeat
      end if
    end repeat
    if tFoundEnd then
      subtract 1 from tCount
      put tStackLines & return before line tCount of gREVObjectTree
    else
      put return & tStackLines after gREVObjectTree
    end if
  end if
  lock screen
  
  local tLineID
  put revSelLineID() into tLineID
  revUpdateTree revTreeHtml(gREVObjectTree), tLineID
  unlock screen
end revMainStackChanged

on revNameChanged pObject, pOldName, pNewName
  global gREVStackName, gREVObjectTree, gREVControls
  
  local tID
  put the id of pObject into tID
  
  local tType
  put word 1 of pObject into tType
  replace comma with kComma in pNewName
  
  local tLineID
  put revSelLineID() into tLineID
  switch tType
  case "stack"
    replace comma with kComma in pOldName
    
    local tStackMatch
    put pOldName,"stack,expanded" into tStackMatch
    
    local tStartLine
    put lineOffset(tStackMatch,gREVObjectTree) into tStartLine
    if tStartLine is 0 then exit revNameChanged
    put pNewName into item 6 of line tStartLine of gREVObjectTree
    
    local tNumLines
    put the num of lines in gREVObjectTree into tNumLines
    repeat with i = tStartLine to tNumLines
      if item 1 of line i of gREVObjectTree is not pOldName then exit repeat
      put pNewName into item 1 of line i of gREVObjectTree
      put pNewName into item 14 of line i of gREVObjectTree
    end repeat
    lock screen
    revUpdateTree revTreeHtml(gREVObjectTree), tLineID
    unlock screen
    break
  case "card"
    local tStack
    put the short name of the owner of pObject into tStack
    replace comma with kComma in tStack
    
    local tMatch
    put ",#####REVID=",tID,"=#####REVID",tStack into tMatch
    
    local tOffset
    put lineOffset(tMatch,gREVObjectTree) into tOffset
    if tOffset is 0 then exit revNameChanged
    put pNewName into item 6 of line tOffset of gREVObjectTree
    
    local tNewHtml
    put revTreeHtml(line tOffset of gREVObjectTree) into tNewHtml
    
    local tHtml
    put the htmlText of field "Cards" into tHtml
    put tNewHtml into line tOffset of tHtml
    lock screen
    revUpdateTree tHtml, tLineID
    unlock screen
    break
  default
    set the wholeMatches to true
    put wordOffset("card", pObject) into tOffset
    local tCard
    put word tOffset to -1 of pObject into tCard
    if revTargetStack(pObject) is gREVStackName and the short name of this card is "Cards and Controls" then
      local tLine
      put revControlLine(tID, gREVControls) into tLine
      if tLine is not 0 then
        put pNewName into item 5 of line tLine of gREVControls
        put pNewName into word 1 to -1 of item 11 of line tLine of gREVControls
        put gREVControls into lControlCache[tCard]    
        lock screen
        revUpdateControlsField true
        unlock screen
      else put empty into lControlCache[tCard]
    else
      -- MW-2007-07-02: [[ Bug 4775 ]] Make sure we refresh audio and video clips if a name has changed
      if revTargetStack(pObject) is gREVStackName then
        if the short name of this card is "Audioclips" then
          send "revRefreshAudio true" to this card of me
        else if the short name of this card is "Videoclips" then
          send "revRefreshVideo true" to this card of me
        end if
      end if
      put empty into lControlCache[tCard]
    end if
    break
  end switch
end revNameChanged

on revNewStack pStack
  global gREVObjectTree, gREVShowStacks
  if not lInitialised then exit revNewStack
  if not gREVShowStacks then put revFilterStacksList(pStack) into pStack
  if pStack is empty then exit revNewStack
  local tStack2
  put pStack into tStack2
  replace comma with kComma in tStack2
  
  local tStackMatch
  put tStack2,"stack,expanded" into tStackMatch
  if tStackMatch is in gREVObjectTree then exit revNewStack
  
  local tHtml
  put the htmlText of field "Cards" into tHtml
  
  local tStacksHtml
  put revStackLine(pStack) into tStacksHtml
  
  local tStackSubstacks
  put the substacks of stack pStack into tStackSubstacks
  sort lines of tStackSubstacks
  repeat for each line l in tStackSubstacks
    put return & revStackLine(l) after tStacksHtml
  end repeat
  if gREVObjectTree is empty then 
    put tStacksHtml into gREVObjectTree
    put revTreeHtml(gREVObjectTree) into tHtml
  else
    put return & tStacksHtml after gREVObjectTree
    put return & revTreeHtml(tStacksHtml) after tHtml
  end if
   
  lock screen
  local tLineID
  put revSelLineID() into tLineID
  revUpdateTree tHtml, tLineID
  unlock screen
end revNewStack

on revAODeleteStack pStack, pStacks
  global gREVObjectTree, gREVStackName
  local tStack
  put pStack into tStack
  replace comma with kComma in tStack
  
  local tStackMatch
  put tStack,"stack,expanded" into tStackMatch
  
  local tStartLine
  put lineOffset(tStackMatch,gREVObjectTree) into tStartLine
  if tStartLine is 0 then exit revAODeleteStack
  
  local tNotEnd
  put false into tNotEnd
  
  local tNumLines
  put the num of lines in gREVObjectTree into tNumLines
   
  replace comma with kComma in pStacks
  repeat with i = tStartLine to tNumLines
    local tLineStack
    put item 1 of line i of gREVObjectTree into tLineStack
    if tLineStack is not among the lines of pStacks then
      put true into tNotEnd
      exit repeat
    end if
  end repeat
  
  if tNotEnd then delete line tStartLine to (i-1) of gREVObjectTree
  else delete line tStartLine to tNumLines of gREVObjectTree 
  
  lock screen
  local tLineID
  put revSelLineID() into tLineID
  revUpdateTree revTreeHtml(gREVObjectTree), tLineID
  if pStack is gREVStackName then set the currentCard of this stack to "blank"
  unlock screen
end revAODeleteStack

on revUpdateCards pStack
  global gREVObjectTree, gREVShowStacks
  if not gREVShowStacks then put revFilterStacksList(pStack) into pStack
  if pStack is empty then exit revUpdateCards
  
  local tStackMatch
  put pStack,"stack,expanded true" into tStackMatch
  
  local tLine
  put lineOffset(tStackMatch,gREVObjectTree) into tLine
  if tLine is 0 then exit revUpdateCards
  
  switch
  case the cShowAudioClips of stack "revPreferences"
    local tMatch
    put ",audioclip,expanded false," into tMatch
    break
  case the cShowVideoClips of stack "revPreferences"
    put ",videoclip,expanded false," into tMatch
    break
  default
    put ",stack,expanded" into tMatch
    break
  end switch
   
  local tLineID
  put revSelLineID() into tLineID
  
  local tMatchLine
  put lineOffset(tMatch,gREVObjectTree,tLine) into tMatchLine
  
  local tEndCardLine
  if tMatchLine = 0 then
    put the num of lines in gREVObjectTree into tEndCardLine
  else 
    put tMatchLine + tLine - 1 into tEndCardLine
  end if
  
  local tCardList
  put revCardList(the cardIDs of stack pStack,pStack) into tCardList
  
  local tHtml
  put the htmlText of field "Cards" into tHtml
  put tCardList into line (tLine + 1) to tEndCardLine of gREVObjectTree
  put revTreeHtml(tCardList) into line (tLine + 1) to tEndCardLine of tHtml
  lock screen
  revUpdateTree tHtml, tLineID
  if lineOffset(tLineID,gREVObjectTree) = 0
  then set the currentCard of this stack to "Blank"
  unlock screen
end revUpdateCards

on revUpdatePalette
  global gREVStackName, gREVControls
  if the short name of this card is not "Cards and Controls" then exit revUpdatePalette
  lock screen
  
  local tTargetStack
  put revTargetStack(line 1 of (the selobj)) into tTargetStack
  
  local tHCAddressing
  put the hcAddressing of stack tTargetStack into tHCAddressing
  set the hcAddressing of stack tTargetStack to false
  
  local tSelobj
  put the selobj into tSelobj
  switch
  case tSelobj is empty
  case word 1 of tSelobj is among the items of "stack,audioClip,videoClip,the"
  case gREVStackName is not tTargetStack
  case word 1 of tSelobj is "card"
    revHiliteControlLine
    put (the num of lines in gREVControls) && "Controls" into field "Control Info"
    break
  default
    local tHilitedLines
    put empty into tHilitedLines
    repeat for each line l in tSelobj
      put revControlLine(word 3 of l, gREVControls) & comma after tHilitedLines
    end repeat
    delete last char of tHilitedLines
    revHiliteControlLine tHilitedLines
    put (the num of lines in gREVControls) && "Controls (" & (the num of items in the hilitedLines of field "Controls") && "selected)" into field "Control Info"
    break
  end switch
  set the hcAddressing of stack tTargetStack to tHCAddressing
  unlock screen
end revUpdatePalette

on revHiliteControlLine pLines
  local tPrevHilitedLines
  put the cPrevHilitedLines of field "Controls" into tPrevHilitedLines
  if tPrevHilitedLines is not 0 then
    repeat for each item i in tPrevHilitedLines
      set the textColor of line i of field "Controls" to empty
    end repeat
  end if
  set the hilitedLines of field "Controls" to pLines
  set the cPrevHilitedLines of field "Controls" to pLines
  if the cSuspended of this stack then
    repeat for each item i in pLines
      set the textColor of line i of field "Controls" to "black"
    end repeat
  end if
end revHiliteControlLine

function revCardOpen
  global gREVStackName
  if the mode of stack gREVStackName is not 0 and the cCardID of this stack is the id of this card of stack gREVStackName
  then return true
  else return false
end revCardOpen

on revRetainStacks
  global gREVObjectTree
  local tStackMatch
  put comma & "stack,expanded true" into tStackMatch
  
  local tSkip
  put 0 into tSkip
  put empty into lCurrentStacks
  repeat
    local tLineOffset
    put lineOffset(tStackMatch,gREVObjectTree,tSkip) into tLineOffset
    if tLineOffset = 0 then exit repeat
    add tLineOffset to tSkip
    put item 1 of line tSkip of gREVObjectTree & return after lCurrentStacks
  end repeat
  delete last char of lCurrentStacks
  replace kComma with comma in lCurrentStacks
end revRetainStacks

function revSelLineID
  global gREVObjectTree
  #returns unique string for selected line in tree view, if there is one
  local tSelLine
  put the cSelLine of field "Cards" of group "Cards" into tSelLine
  if tSelLine is not empty
  then return item 4 to 14 of line tSelLine of gREVObjectTree
  else return empty
end revSelLineID

on revReselectLine pLineID
  global gREVObjectTree
  #reselects line in tree view using ID from revSelLineID()
  
  if pLineID is not empty then
    local tLineOffset
    put lineOffset(pLineID,gREVObjectTree) into tLineOffset
    if tLineOffset is not 0 then revSelectLine tLineOffset
  end if
end revReselectLine

on revSelectLine pLine
  local tLine
  put the cSelLine of field "Cards" of group "Cards" into tLine
  set the itemDel to tab
  if tLine is not empty then
    set the backColor of word 1 to -1 of item 1 of line tLine of field "Cards" of group "Cards" to empty
    set the textColor of word 1 to -1 of item 1 of line tLine of field "Cards" of group "Cards" to empty
  end if
  set the backColor of word 1 to -1 of item 1 of line pLine of field "Cards" of group "Cards" to the hiliteColor
  if the platform is not "MacOS" 
  then set the textColor of word 1 to -1 of item 1 of line pLine of field "Cards" of group "Cards" to "white"
  set the cSelLine of field "Cards" of group "Cards" to pLine
end revSelectLine

function revLastTabRight pField
  local tRight
  if the vScrollbar of pField then 
    put the right of pField - the scrollbarWidth of pField into tRight
  else 
    put the right of pField into tRight
  end if
  
  return max(tRight, the left of pField + the formattedWidth of pField - the hScroll of pField)
end revLastTabRight

function revShortCutAction pObjectType
  switch
  case the commandKey is down
    return the cABCommandDoubleClick[pObjectType] of stack "revPreferences"
    break
  case the optionKey is down
    return the cABOptionDoubleClick[pObjectType] of stack "revPreferences"
    break
  default
    return the cABDoubleClick[pObjectType] of stack "revPreferences"
    break
  end switch
end revShortCutAction

on revSetBlankLeft
  set the left of field "select a card" of card "blank" to the right of button "Resize" of card "blank"
end revSetBlankLeft

on suspendStack
  if the platform is not "Win32" then exit suspendStack
  set the cSuspended of this stack to true
  
  local tLine
  put the cSelLine of field "Cards" of group "Cards" into tLine
  lock screen
  if tLine is not empty then
    set the itemDel to tab
    set the backColor of word 1 to -1 of item 1 of line tLine of field "Cards" of group "Cards" to 236,233,216
    set the textColor of word 1 to -1 of item 1 of line tLine of field "Cards" of group "Cards" to empty
    set the itemDel to comma
  end if
  set the hiliteColor of this stack to 236,233,216
  
  local tField
  put empty into tField
  switch the short name of this cd
  case "Cards and Controls"
    put "Controls" into tField
    break
  case "Audioclips"
  case "Videoclips"
    put the short name of this card into tField
    break
  end switch
  if tField is not empty then
    repeat for each item i in the hilitedLines of field tField
      set the textColor of line i of field tField to "black"
    end repeat
  end if
  unlock screen
end suspendStack

on resumeStack
  if the platform is not "Win32" then exit resumeStack
  set the cSuspended of this stack to false
  
  local tLine
  put the cSelLine of field "Cards" of group "Cards" into tLine
  lock screen
  if tLine is not empty then
    set the itemDel to tab
    set the backColor of word 1 to -1 of item 1 of line tLine of field "Cards" of group "Cards" to the hiliteColor
    set the textColor of word 1 to -1 of item 1 of line tLine of field "Cards" of group "Cards" to "white"
    set the itemDel to comma
  end if
  set the hiliteColor of this stack to empty
  
  local tField
  put empty into tField
  switch the short name of this cd
  case "Cards and Controls"
    put "Controls" into tField
    break
  case "Audioclips"
  case "Videoclips"
    put the short name of this card into tField
    break
  end switch
  if tField is not empty then
    repeat for each item i in the hilitedLines of field tField
      set the textColor of line i of field tField to empty
    end repeat
  end if
  unlock screen
end resumeStack

on revSelectInListField pField, pButton
  if the num of words in the text of pField is 0 then
    set the hilitedLines of pField to empty
    exit revSelectInListField
  end if
  
  local tMouseLine
  put revFieldMouseLine(pField) into tMouseLine
  if the commandKey is down then
    local tHilitedLines
    put the hilitedLines of pField into tHilitedLines
    if tMouseLine is among the items of tHilitedLines then 
      if pButton is not 3 then
        delete item itemOffset(tMouseLine, tHilitedLines) of tHilitedLines
      end if
    else
      if tHilitedLines is empty
      then put tMouseLine into tHilitedLines
      else put comma&tMouseLine after tHilitedLines
    end if
    set the hilitedLines of pField to tHilitedLines
  else set the hilitedLine of pField to tMouseLine
end revSelectInListField

function revFieldMouseLine pField
  #Required instead of the built-in mouseLine function as the built-in one 
  #returns empty when clicking a line in the field when the popup menu is open.
  local tMouseLine
  put 1 + round((the mouseV - the top of pField - the topMargin of pField - 5 + the scroll of pField) / the textHeight of pField) into tMouseLine
  if tMouseLine > the num of lines in the text of pField
  then return empty
  else return tMouseLine
end revFieldMouseLine

on log pMsg
  put pMsg & return after msg
end log

on tTPLinkColours
   
end tTPLinkColours


