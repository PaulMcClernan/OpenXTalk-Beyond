script "stack_App_Browser_card_id_1002"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kTabs="Type,Visible,Selectable,Layer,Control,ID,Script Lines"

on resizeStack
  -- OK-2006-09-18
  -- Modified to allow stack script to handle this message
  local tHilitedLines
  put the hilitedLines of field "Controls" into tHilitedLines
  revUpdateGeometry  -- dunno why this was disabled but it broke 4953 KM
  set the hilitedLines of field "Controls" to tHilitedLines
  revSetVScrollbar the long id of field "Controls", the long id of group "Control Tabs"
  
  local tTab
  put item (the last item of the cControlTabs of group "Control Tabs") of kTabs into tTab
  set the rect of button tTab of group "Control Tabs" to the topLeft of button tTab of group "Control Tabs", \
      revLastTabRight(the long id of field "Controls"), the bottom of button tTab of group "Control Tabs"
  set the hScroll of group "Control Tabs" to the hScroll of field "Controls"
  --revResizeBrowser
  pass resizeStack
end resizeStack

on revSetControlsLeft
  local tHilitedLine
  put the hilitedLine of field "Controls" into tHilitedLine
  set the rect of field "Controls" to the right of button "Resize", \
      the top of field "Controls", the bottomRight of field "Controls"
  set the hilitedLine of field "Controls" to tHilitedLine
  set the width of group "Control Tabs" to the width of field "Controls"
  set the left of group "Control Tabs" to the right of button "Resize"
  set the left of field "Control Info" to right of button "Resize" - 1
end revSetControlsLeft

function revSelControls
   global gREVStackName, gREVControls
   if gREVControls is empty then return empty
   
   local tObjects
   put empty into tObjects
   
   local tLines
   put the hilitedLines of field "Controls" into tLines
   
   local tLayerItem
   put itemOffset("Layer", kTabs) into tLayerItem
   repeat for each item i in tLines
      try
         put the long id of control (item tLayerItem of line i of gREVControls) of card id (the cCardID of this stack) of stack gREVStackName & return after tObjects
      catch e
      end try
   end repeat
   delete last char of tObjects
   return tObjects
end revSelControls


