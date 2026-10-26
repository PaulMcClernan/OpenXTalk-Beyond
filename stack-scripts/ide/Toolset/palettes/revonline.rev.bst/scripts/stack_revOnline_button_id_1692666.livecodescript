script "stack_revOnline_button_id_1692666"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > button "Gradient Bar" (id 1692666)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

private function createGradientBar pRect, pName, pColor
   local tBar
   reset the templateGraphic
   create graphic pName in me
   put the long id of it into tBar
   set the style of tBar to "rectangle"
   set the opaque of tBar to true
   set the lineSize of tBar to 0
   set the antiAliased of tBar to true
   set the rect of tBar to pRect
   
   local tGradient
   put "good" into tGradient["quality"]
   put "linear" into tGradient["type"]
   put "false" into tGradient["wrap"]
   put "false" into tGradient["mirror"]
   put 1 into tGradient["repeat"]
   put "0.00000," & pColor & return & "1.00000,25,25,25" into tGradient["ramp"]
   put item 1 of the loc of tBar & comma & the top of tBar - 20 into tGradient["to"]
   put item 1 of the loc of tBar & comma & the bottom of tBar into tGradient["from"]
   put item 1 of the loc of tBar - 20 & comma & the bottom of tBar into tGradient["via"]
   
   set the fillGradient of tBar to tGradient
end createGradientBar

command update pPercentage, pColor, pCreateFrame
   lock screen
   if there is a graphic "Frame" of me then
      delete graphic "Frame" of me
   end if
   
   if there is a graphic "Background" of me then
      delete graphic "Background" of me
   end if
   
   if there is a graphic "Bar" of me then
      delete graphic "Bar" of me
   end if
   
   local tMargin
   put 3 into tMargin
   
   local tHeight
   put the height of me into tHeight
   
   local tWidth
   put the width of me into tWidth
   
   local tTopLeft
   put the topLeft of me into tTopLeft
   
   local tGroup
   put the long id of me into tGroup
   set the margins of tGroup to 0
   set the lockLocation of tGroup to true
   
   # Create frame
   if pCreateFrame is not false then
      local tFrame
      reset the templateGraphic
      create graphic "Frame" in tGroup
      put the long id of it into tFrame
      set the lineSize of tFrame to 1
      set the opaque of tFrame to false
      set the style of tFrame to "rectangle"
      set the rect of tFrame to (item 1 of tTopLeft), (item 2 of tTopLeft), (item 1 of tTopLeft + tWidth), (item 2 of tTopLeft + tHeight)
      set the foregroundColor of tFrame to "128,128,128"
   end if
   
   # Create background
   local tBackground
   reset the templateGraphic
   create graphic "Background" in tGroup
   put the long id of it into tBackground
   set the lineSize of tBackground to 0
   set the opaque of tBackground to true
   set the style of tBackground to "rectangle"
   set the rect of tBackground to (item 1 of tTopLeft + tMargin), (item 2 of tTopLeft + tMargin), (item 1 of tTopLeft + tWidth - tMargin), (item 2 of tTopLeft + tHeight - tMargin)
   set the backgroundColor of tBackground to "117,116,116"
   
   # Create gradient bar
   local tRect
   put the rect of tBackground into tRect
   
   local tInversePercentage
   put 100 - pPercentage into tInversePercentage
   
   local tDifference
   put the width of tBackground * (tInversePercentage / 100) into tDifference
   put round(tDifference) into tDifference
   subtract tDifference from item 3 of tRect
   
   get createGradientBar(tRect, "Bar", pColor)
   unlock screen
end update
