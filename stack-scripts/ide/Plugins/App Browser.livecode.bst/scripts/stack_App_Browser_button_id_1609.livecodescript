script "stack_App_Browser_button_id_1609"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "common menus" (id 1606) > button "VideoClip Popup" (id 1609)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseRelease pButton
  if the clickLoc is within the rect of fld "Videoclips" then
    send "mouseDown pButton" to fld "Videoclips"
    send "mouseUp pButton" to fld "Videoclips"
  end if
end mouseRelease

on menuPick pWhich
  global gREVStackName, gREVvideoclips
  put revSelvideoclips() into tvideoclips
  switch pWhich
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
    choose browse tool
    repeat for each item i in the hilitedLines of fld "videoclips"
      play videoclip (item 1 of line i of gREVvideoclips) of stack gREVStackName
    end repeat
    break
  case "Stop"
    play stop
    break
  case "Delete"
    repeat for each line l in tvideoclips
      delete l
    end repeat
    revRefreshVideo true
    
    # OK-2008-03-20: Bug 6158
    -- OXT-Beyond: the IDE's handler (it was revSetEdited, which does not exist)
    revIDESetEdited (the short name of stack gREVStackName)
    
    break
  end switch
end menuPick
