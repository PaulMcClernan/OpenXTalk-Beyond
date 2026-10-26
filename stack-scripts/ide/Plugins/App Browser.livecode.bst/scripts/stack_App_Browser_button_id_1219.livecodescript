script "stack_App_Browser_button_id_1219"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "Cards" (id 1583) > button "Resize" (id 1219)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMouseDown, lHOffset
constant kTabs="Name,Num,ID,Script Lines,Marked"

on mouseDown
  put true into lMouseDown
  put the mouseH - the left of me into lHOffset
end mouseDown

on mouseMove x,y
  if lMouseDown then 
    local tLeft
    put max(the left of field "Cards" + 160,x - lHOffset) into tLeft
    put min(tLeft, the width of this stack - 50) into tLeft
    revResizeWidget tLeft
  end if
end mouseMove

on revResizeWidget pLeft
  lock screen
  set the left of me to pLeft
  set the cAppBrowserWidgetLeft of stack "revPreferences" to pLeft
  set the rect of field "Cards" to the topLeft of field "Cards", the left of me, the bottom of field "Cards"
  set the rect of group "Card Tabs" to the topLeft of group "Card Tabs", the left of me, the bottom of group "Card Tabs"
  set the rect of group "Cards" to the topLeft of group "Cards", the right of me, the bottom of group "Cards"
  
  local tTab
  put item ((the last item of the cCardTabs of group "Card Tabs") - 5) of kTabs into tTab
  set the rect of button tTab of group "Card Tabs" to the topLeft of button tTab of group "Card Tabs", revLastTabRight(the long id of field "Cards"), the bottom of button tTab of group "Card Tabs"
   
  switch the short name of this card
  case "Blank"
    revSetBlankLeft
    break
  case "Cards and Controls"
    revSetControlsLeft
    break
  case "Audioclips"
    revSetAudioclipsLeft
    break
  case "Videoclips"
    revSetVideoclipsLeft
    break
  end switch
  resizeStack
  unlock screen
end revResizeWidget

on mouseUp
  revMouseUp
end mouseUp

on mouseRelease
  unlock cursor
  revMouseUp
end mouseRelease

on mouseDoubleUp
  revMouseUp
end mouseDoubleUp

on revMouseUp
  put false into lMouseDown
end revMouseUp

on mouseEnter
  lock cursor
  set the cursor to 31
end mouseEnter

on mouseLeave
  unlock cursor
end mouseLeave
