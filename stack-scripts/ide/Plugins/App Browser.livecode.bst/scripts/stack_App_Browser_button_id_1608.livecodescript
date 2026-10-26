script "stack_App_Browser_button_id_1608"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "common menus" (id 1606) > button "Audioclip Popup" (id 1608)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseRelease pButton
  if the clickLoc is within the rect of fld "Audioclips" then
    send "mouseDown pButton" to fld "Audioclips"
    send "mouseUp pButton" to fld "Audioclips"
  end if
end mouseRelease

on menuPick pWhich
  global gREVStackName, gREVAudioclips
  put revSelAudioClips() into tAudioclips
  switch pWhich
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
  case "Stop"
    play stop
    break
  case "Delete"
    repeat for each line l in tAudioclips
      delete l
    end repeat
    revRefreshAudio true
    
    # OK-2008-03-20
    -- OXT-Beyond: the IDE's handler (it was revSetEdited, which does not exist)
    revIDESetEdited (the short name of stack gREVStackName)
    break
  end switch
end menuPick
