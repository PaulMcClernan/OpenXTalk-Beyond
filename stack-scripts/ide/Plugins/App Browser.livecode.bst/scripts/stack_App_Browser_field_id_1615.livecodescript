script "stack_App_Browser_field_id_1615"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Audioclips" (id 1580) > field "AudioClips" (id 1615)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lTypeText, lClearTimerID

on mouseDown pButton
  revSelectInListField the long id of me, pButton
  if the num of words in the text of me > 0 \
      and the platform is "MacOS" and pButton is 3 then revAudioclipFieldPopup
end mouseDown

on mouseUp pButton
  if the platform is not "MacOS" and pButton is 3 \
  and the num of words in the text of me > 0 then revAudioclipFieldPopup
end mouseUp

on mouseDoubleUp
  global gREVStackName, gREVAudioclips
  put revSelAudioClips() into tAudioclips
  put revShortCutAction("audioclips") into tAction 
  switch tAction
  case "Property Inspector"
    repeat for each line l in tAudioclips
      send "revBuildPropertyPalette l" to stack "revTemplatePalette"
    end repeat
    break
  case "Edit Script"
    repeat for each line l in tAudioclips
      edit script of l
    end repeat
    break
  case "Play"
    --can't use long id
    repeat for each item i in the hilitedLines of fld "Audioclips"
      play audioclip (item 1 of line i of gREVAudioclips) of stack gREVStackName
    end repeat
    break
  end switch
end mouseDoubleUp

on revAudioclipFieldPopup
  global gREVStackName
  if the hilitedLine of me is empty then exit revAudioclipFieldPopup
  if the mode of stack gREVStackName is 0
  then put "(Play" & cr & "(Stop" into line 4 to 5 of btn "Audioclip popup"
  else put "Play" & cr & "Stop" into line 4 to 5 of btn "Audioclip popup"
  popup btn "Audioclip popup" at the clickLoc
end revAudioclipFieldPopup

on mouseEnter
  mouseMove
end mouseEnter

on mouseMove
  if "revShowAudioclipTips" is not among the items of the pendingMessages
  then send "revShowAudioclipTips" to me in 500 milliseconds
end mouseMove

on revShowAudioclipTips
  global gREVAudioclips, gREVStackName
  lock screen
  set the tooltip of me to empty
  put revFieldMouseLine(the long id of me) into tLine
  if tLine is not empty then
    put item 1 of line tLine of gREVAudioclips into tNum
    if tNum is not empty then
      if there is a Audioclip tNum of stack gREVStackName 
      then set the tooltip of me to the long id of Audioclip tNum of stack gREVStackName
    end if
  end if
  unlock screen
end revShowAudioclipTips

on scrollbarDrag
  put the hScroll of me into tHScroll
  if the hScroll of grp "Audioclip Tabs" is not tHScroll
  then set the hScroll of grp "Audioclip Tabs" to tHScroll
end scrollbarDrag

-----------------------------------------------
Scripts for selection by the keyboard
-----------------------------------------------
 
on keyDown pKey
  if lClearTimerID is not empty then cancel lClearTimerID
  put pKey after lTypeText
  put lTypeText into fld "Audioclip Info"
  if "revSelectTyped" is not among the items of the pendingMessages
  then send "revSelectTyped" to me in 500 milliseconds
end keyDown

on revSelectTyped
  if the short name of this cd is not "AudioClips" then exit revSelectTyped
  put 0 into tLine
  put the text of me into tAudioclips
  set the itemDel to tab
  repeat for each line l in tAudioclips
    add 1 to tLine
    put the num of chars in lTypeText into tNumChars
    if lTypeText is char 1 to tNumChars of item 2 of l then
      set the hilitedLine of fld "Audioclips" to tLine
      exit repeat
    end if
  end repeat
  send "revClearTyped" to me in 1500 milliseconds
  put the result into lClearTimerID
end revSelectTyped

on revClearTyped
  global gREVStackName, gREVAudioclips
  if the short name of this cd is not "AudioClips" then exit revClearTyped
  
  put empty into lTypeText
  put empty into fld "Audioclip info"  
end revClearTyped

-----------------------------------------------
