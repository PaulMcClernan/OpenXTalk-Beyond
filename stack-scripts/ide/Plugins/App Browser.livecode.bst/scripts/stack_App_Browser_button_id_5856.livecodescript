script "stack_App_Browser_button_id_5856"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > button "No selection control popup" (id 5856)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseRelease pButton
  if the clickLoc is within the rect of fld "Controls" then
    send "mouseDown pButton" to fld "Controls"
    send "mouseUp pButton" to fld "Controls"
  end if
end mouseRelease

on menuPick pWhich
  global gREVStackName
  switch pWhich
  case "Paste"
    set the defaultStack to gREVStackName
    paste
    break
  case "Refresh"
    revRefreshControls true, false
    break
  end switch
end menuPick
