script "stack_App_Browser_field_id_1029"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "Cards" (id 1583) > field "Cards" (id 1029)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lTypeText, lClearTimerID
constant kComma="######REVCOMMA#####", kLessThan="['less than' character]"

on revClickTree
  global gREVObjectTree
  if the mouseLine is empty then exit revClickTree
  
  local tLine
  put word 2 of the mouseLine into tLine
  
  local tDisplayName
  put item 6 of line tLine of gREVObjectTree into tDisplayName
  replace kComma with comma in tDisplayName
  replace tab with space & space in tDisplayName
  replace "<" with kLessThan in tDisplayName
  if the mouseText is not tDisplayName then exit revClickTree
  revSelectAndGo tLine
end revClickTree

on revSelectAndGo pLine
  global gREVObjectTree
  
  local tTreeLine
  put line pLine of gREVObjectTree into tTreeLine
  
  local tStack
  put item 1 of tTreeLine into tStack
  replace kComma with comma in tStack
  if (there is not a stack tStack) \
      or (item 2 of tTreeLine is "card" and \
      there is not a cd id (item 8 of tTreeLine) of stack tStack) then
    revRefreshTree
    exit revSelectAndGo
  end if
  revSelectTree pLine
  revSelectLine pLine
end revSelectAndGo

on revSelectTree pLine
   global gREVStackName, gREVObjectTree
   
   put item 1 of line pLine of gREVObjectTree into gREVStackName
   replace kComma with comma in gREVStackName
   -- sanity check (tperry 29-6-24)
   if not(there is a stack gREVStackName) then exit revSelectTree
   
   local tType
   put item 2 of line pLine of gREVObjectTree into tType
   switch tType
      case "stack"
         go cd "Blank"
         set the cCardID of this stack to empty
         if there is a stack gREVStackName then put (the num of cds in stack gREVStackName) && "Cards" into fld "Card Info" of group "Cards"
         revSetBlankLeft
         resizeStack
         break
      case "card"
         if the short name of this cd is not "Cards and Controls"
         then go cd "Cards and Controls"
         set the cCardID of this stack to item 8 of line pLine of gREVObjectTree
         if not (there is a stack gREVStackName) then exit revSelectTree
         -- sanity check (tperry 28-6-24)
         if the editBg of stack gREVStackName then set the editBg of stack gREVStackName to false
         --
         put (the num of cds in stack gREVStackName) && "Cards" into fld "Card Info" of group "Cards"
         revRefreshControls false, true
         revSetControlsLeft
         resizeStack
         break
      case "audioclip"
         go cd "Audioclips"
         put (the num of audioclips in stack gREVStackName) && "Audioclips" \
               into fld "Card Info" of group "Cards"
         set the cCardID of this stack to empty
         revRefreshAudio false
         revSetAudioclipsLeft
         resizeStack
         break
      case "videoclip"
         go cd "Videoclips"
         put (the num of videoclips in stack gREVStackName) && "VideoClips" \
               into fld "Card Info" of group "Cards"
         set the cCardID of this stack to empty
         revRefreshVideo false
         revSetVideoclipsLeft
         resizeStack
         break
   end switch
end revSelectTree

on mouseUp pButton
  global gREVObjectTree, gREVStackName
  lock screen
  revClickTree
  if the platform is not "MacOS" and pButton is 3 then revCardFieldPopup
  else
    local tLine
    put word 2 of the clickLine into tLine
    
    local tClickChunk
    put the clickChunk into tClickChunk
    
    local tStack
    put item 1 of line tLine of gREVObjectTree into tStack
    replace kComma with comma in tStack
    put the clickCharChunk into tClickChunk
    if tClickChunk is not empty then
      local tHtml
      put the htmlText of field "Cards" into tHtml
      
      local tNextStack
      put comma & "stack", "expanded" into tNextStack
      
      local tLineOffset
      put lineOffset(tNextStack, gREVObjectTree, tLine) into tLineOffset
      
      local tEndLine
      if tLineOffset = 0 then put the num of lines in gREVObjectTree into tEndLine
      else put tLineOffset + tLine - 1 into tEndLine
      
      local tLineID
      put revSelLineID() into tLineID
      
      local tImageSource
      put the imageSource of tClickChunk into tImageSource
      switch tImageSource
      case revInIcon()
        --fold out
        if the num of cds in stack tStack > 30 or the num of lines in fld "Cards" > 100
        then set the cursor to watch
         
        local tCards
        put line tLine of gREVObjectTree into tCards
        put "expanded true" && revOutIcon() into item 3 of line 1 of tCards
        if the editBg of stack tStack then set the editBg of stack tStack to false
        put cr & revCardList(the cardIDs of stack tStack,tStack) after tCards
        if the cShowAudioClips of stack "revPreferences"
        then put cr & revAudioClipLine(tStack) after tCards
        if the cShowVideoClips of stack "revPreferences"
        then put cr & revVideoClipLine(tStack) after tCards
        put tCards into line tLine to tEndLine of gREVObjectTree
        put revTreeHtml(tCards) into line tLine to tEndLine of tHtml
        revUpdateTree tHtml, tLineID
        break
      case revOutIcon()
        --fold in
        if the num of cds in stack tStack > 30 or the num of lines in fld "Cards" > 100
        then set the cursor to watch
         
        local tSourceLine
        put line tLine of gREVObjectTree into tSourceLine
        put "expanded false" && revInIcon() into item 3 of line 1 of tSourceLine
        put tSourceLine into line tLine to tEndLine of gREVObjectTree
        put revTreeHtml(tSourceLine) into line tLine to tEndLine of tHtml
        revUpdateTree tHtml, tLineID
        
        break
      case the cMainStackIcon of this stack
      case the cSubstackIcon of this stack
      case the cCardIcon of this stack
      case the cAudioclipIcon of this stack
      case the cVideoclipIcon of this stack
        revSelectAndGo tLine
        break
      end switch
    end if
     
    if 10 is in the cCardTabs of group "Card Tabs" then
      local tClickH
      put the clickH into tClickH
      if tClickH > the left of button "Marked" of group "Card Tabs" \
          and tCLickH < the right of button "Marked" of group "Card Tabs" \
          and (there is a cd id (item 8 of line tLine of gREVObjectTree) \
          of stack tStack) then
         
        local tMarkItemNum
        put 3 into tMarkItemNum
        if 8 is among the items of the cCardTabs of group "Card Tabs"
        then add 1 to tMarkItemNum
        if 9 is among the items of the cCardTabs of group "Card Tabs"
        then add 1 to tMarkItemNum
         
        local tNewMark
        put not item 10 of line tLine of gREVObjectTree into tNewMark
        put tNewMark into item 10 of line tLine of gREVObjectTree
        set the mark of cd id (item 8 of line tLine of gREVObjectTree) of stack tStack to tNewMark
        set the itemDel to tab
        if tNewMark then
          set the imageSource of char 1 of item tMarkItemNum of line tLine of field "Cards" to the cTickIcon of this stack
        else
          set the imageSource of char 1 of item tMarkItemNum of line tLine of field "Cards" to the cUnTickIcon of this stack
        end if
      end if
    end if
  end if
  unlock screen
  pass mouseUp
end mouseUp

on mouseDoubleUp
  global gREVObjectTree
  local tLine
  put line (word 2 of the mouseLine) of gREVObjectTree into tLine
  
  local tStack
  put item 1 of tLine into tStack
  replace kComma with comma in tStack
  
  local tType
  put item 2 of tLine into tType
  
  local tKey
  put tType & "s" into tKey
  
  local tAction
  put revShortCutAction(tKey) into tAction
  switch tType
  case "card"
    local tCard
    put the long id of card id (item 8 of tLine) of stack tStack into tCard
    switch tAction
    case "Property Inspector"
      if (the selobj) is tCard
      then send "revBuildPropertyPalette" to stack "revTemplatePalette"    
      else send "revBuildPropertyPalette tCard" to stack "revTemplatePalette"
      break
    case "Edit Script"
      edit script of tCard
      break
    default
      if not the visible of stack tStack then show stack tStack
      go cd id (item 8 of tLine) of stack tStack
      break
    end switch
    break
  case "stack"
    switch tAction
    case "Property Inspector"
      if the selobj is the long id of stack tStack
      then send "revBuildPropertyPalette" to stack "revTemplatePalette"    
      else send "revBuildPropertyPalette the long id of stack tStack" to stack "revTemplatePalette"
      break
    case "Edit Script"
      if not the visible of stack tStack then show stack tStack
      edit script of stack tStack
      break
    default
      if not the visible of stack tStack then show stack tStack
      if the style of stack tStack is not "toplevel"
      then set the style of stack tStack to "toplevel"
      else toplevel stack tStack
      break
    end switch
    break
  end switch
end mouseDoubleUp

on mouseDown pButton
  if the platform is "MacOS" and pButton is 3 then revCardFieldPopup
  pass mouseDown
end mouseDown

on revCardFieldPopup
  global gREVObjectTree
  local tLine
  put word 2 of the mouseLine into tLine
  
  local tObject
  put item 2 of line tLine of gREVObjectTree into tObject
  switch tObject
  case "card"
    set the cLine of button "Card Popup" to tLine
    popup button "Card popup" at the clickLoc
    break
  case "stack"
    local tStack
    put item 6 of line tLine of gREVObjectTree into tStack
    replace kComma with comma in tStack
    if the mainStack of stack tStack is tStack
    then put "(Delete Substack" into line 8 of button "Stack popup"
    else put "Delete Substack" into line 8 of button "Stack popup"
     
    set the cLine of button "Stack Popup" to tLine
    popup button "Stack popup" at the clickLoc
    break
  case "audiclip"
    break
  case "videoclip"
    break
  end switch
end revCardFieldPopup

on mouseEnter
  mouseMove
end mouseEnter

on mouseMove
  if "revShowToolTip" is not among the items of the pendingMessages
  then send "revShowToolTip" to me in 500 milliseconds
end mouseMove

on revShowToolTip
  global gREVObjectTree
  
  # OK-2007-07-03: Bug 897
  -- set the tooltip of me to empty
  
  local tLine
  put word 2 of the mouseLine into tLine
  
  local tStack
  put item 1 of line tLine of gREVObjectTree into tStack
  replace kComma with comma in tStack
  
  local tObjectType
  put item 2 of line tLine of gREVObjectTree into tObjectType
  
  local tToolTip
  put empty into tToolTip
  switch tObjectType
  case "stack"
    if there is a stack tStack
    then put the long id of stack tStack into tToolTip
    break
  case "card"
    local tID
    put item 8 of line tLine of gREVObjectTree into tID
    if there is a cd id tID of stack tStack
    then put the long id of cd id tID of stack tStack into tToolTip
    break
  case "audioclip"
    if there is a stack tStack 
    then put (the num of audioclips in stack tStack) && "AudioClips in stack" && tStack into tToolTip
    break
  case "videoclip"
    if there is a stack tStack
    then put (the num of videoclips in stack tStack) && "VideoClips in stack" && tStack into tToolTip
    break
  end switch
  if the toolTip of me is not tToolTip then
    set the toolTip of me to empty -- seems to need to refresh, don't lock screen or field backColor flickers
    set the toolTip of me to tToolTip
  end if
end revShowToolTip

on scrollbarDrag
  local tHScroll
  put the hScroll of me into tHScroll
  if the hScroll of group "Card Tabs" is not tHScroll
  then set the hScroll of group "Card Tabs" to tHScroll
end scrollbarDrag

-----------------------------------------------
Scripts for selection by the keyboard
-----------------------------------------------
 
on keyDown pKey
  if lClearTimerID is not empty then cancel lClearTimerID
  put pKey after lTypeText
  put lTypeText into fld "Card Info"
  if "revSelectMatch" is not among the items of the pendingMessages
  then send "revSelectMatch" to me in 500 milliseconds
end keyDown

on revSelectMatch
  local tLine
  put 0 into tLine
  
  local tCards
  put the text of me into tCards
  set the itemDel to tab
  repeat for each line tCard in tCards
    add 1 to tLine
    local tNumChars
    put the num of chars in lTypeText into tNumChars
    if lTypeText is char 1 to tNumChars of word 1 to -1 of item 1 of tCard then
      revSelectAndScroll tLine
      exit repeat
    end if
  end repeat
  send "revClearMatch" to me in 1500 milliseconds
  put the result into lClearTimerID
end revSelectMatch

on revSelectAndScroll pLine
  lock screen
  local tHeight
  put the height of me into tHeight
  if the hScrollbar of me then subtract the scrollbarWidth of me from tHeight
  if (pLine * the textHeight of me) < the scroll of me + the height of button "Name" of group "Card Tabs"
  then set the scroll of me to (pLine * the textHeight of me) - the height of button "Name" of group "Card Tabs"
  else if pLine * the textHeight of me + the topMargin of me > the scroll of me + tHeight
  then set the scroll of me to (pLine * the textHeight of me) - tHeight + the topMargin of me
  revSelectAndGo pLine
  unlock screen
end revSelectAndScroll

on revClearMatch
  put empty into lTypeText
  if not (word 1 of field "Card Info" is a number and word 2 of field "Card Info" is among the items of "Cards,Videoclips,Audioclips")
  then put empty into field "Card Info"  
end revClearMatch

on arrowKey pWhich
  local tLine
  put the cSelLine of me into tLine
  if pWhich is "down" then
    local tUpDown
    put true into tUpDown
    if tLine < the num of lines in me then 
      add 1 to tLine
    end if
  else if pWhich is "up" then
    put true into tUpDown
    if tLine > 1 then subtract 1 from tLine
  end if
  if tUpDown then
    revSelectAndScroll tLine
  end if
end arrowKey
