script "stack_App_Browser_field_id_4164"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "VideoClips" (id 1581) > field "Videoclips" (id 4164)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lTypeText, lClearTimerID

on mouseDown pButton
  revSelectInListField the long id of me, pButton
  if the num of words in the text of me > 0 \
      and the platform is "MacOS" and pButton is 3 then revvideoclipFieldPopup
end mouseDown

on mouseUp pButton
  global gREVvideoclips, gREVStackName
  if the platform is not "MacOS" and pButton is 3 \
  and the num of words in the text of me > 0 then revvideoclipFieldPopup
end mouseUp

on mouseDoubleUp
  global gREVStackName, gREVvideoclips
  put revSelvideoClips() into tvideoclips
  put revShortCutAction("videoclips") into tAction
  switch tAction
  case "Property Inspector"
    repeat for each line l in tvideoclips
      send "revBuildPropertyPalette l" to stack "revTemplatePalette"
    end repeat
    break
  case "Edit Script"
    repeat for each line l in tvideoclips
      edit script of l
    end repeat
    break
  case "Play"
    --can't use long id
    repeat for each item i in the hilitedLines of fld "videoclips"
      play videoclip (item 1 of line i of gREVvideoclips) of stack gREVStackName
    end repeat
    break
  end switch
end mouseDoubleUp

on revvideoclipFieldPopup
  global gREVStackName
  if the hilitedLine of me is empty then exit revvideoclipFieldPopup
  if the mode of stack gREVStackName is 0
  then put "(Play" & cr & "(Stop" into line 4 to 5 of btn "videoclip popup"
  else put "Play" & cr & "Stop" into line 4 to 5 of btn "videoclip popup"
  popup btn "videoclip popup" at the clickLoc
end revvideoclipFieldPopup

on mouseEnter
  mouseMove
end mouseEnter

on mouseMove
  if "revShowvideoclipTips" is not among the items of the pendingMessages
  then send "revShowvideoclipTips" to me in 500 milliseconds
end mouseMove

on revShowvideoclipTips
  global gREVvideoclips, gREVStackName
  lock screen
  set the tooltip of me to empty
  put revFieldMouseLine(the long id of me) into tLine
  if tLine is not empty then
    put item 1 of line tLine of gREVvideoclips into tNum
    if tNum is not empty then
      if there is a videoclip tNum of stack gREVStackName 
      then set the tooltip of me to the long id of videoclip tNum of stack gREVStackName
    end if
  end if
  unlock screen
end revShowvideoclipTips

on scrollbarDrag
  put the hScroll of me into tHScroll
  if the hScroll of grp "videoclip Tabs" is not tHScroll
  then set the hScroll of grp "videoclip Tabs" to tHScroll
end scrollbarDrag

-----------------------------------------------
Scripts for selection by the keyboard
-----------------------------------------------
 
on keyDown pKey
  if lClearTimerID is not empty then cancel lClearTimerID
  put pKey after lTypeText
  put lTypeText into fld "videoclip Info"
  if "revSelectTyped" is not among the items of the pendingMessages
  then send "revSelectTyped" to me in 500 milliseconds
end keyDown

on revSelectTyped
  if the short name of this cd is not "VideoClips" then exit revSelectTyped
  put 0 into tLine
  put the text of me into tvideoclips
  set the itemDel to tab
  repeat for each line l in tvideoclips
    add 1 to tLine
    put the num of chars in lTypeText into tNumChars
    if lTypeText is char 1 to tNumChars of item 2 of l then
      set the hilitedLine of fld "videoclips" to tLine
      exit repeat
    end if
  end repeat
  send "revClearTyped" to me in 1500 milliseconds
  put the result into lClearTimerID
end revSelectTyped

on revClearTyped
  global gREVStackName, gREVvideoclips
  if the short name of this cd is not "VideoClips" then exit revClearTyped
  
  put empty into lTypeText
  put empty into fld "videoclip info"  
end revClearTyped

-----------------------------------------------
