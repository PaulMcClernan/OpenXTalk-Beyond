script "stack_Message_Box_group_id_1612"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Multiple Lines" (id 1198) > group "fields" (id 1612)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeControl
   local tHeaderHeight, tResultsHeight, tLeft, tTop, tRight, tBottom, tWidth, tLineXLoc, tLineYLoc
   
   lock messages
   lock screen
   
   put the headerHeight of this stack into tHeaderHeight
   put the height of field "results" into tResultsHeight
   
   put the left of me into tLeft
   put the top of me into tTop
   put the right of me into tRight
   put the bottom of me into tBottom
   
   put the width of group "fields" into tWidth
   set the width of graphic "line" to tWidth
   put tWidth/2 into tLineXLoc
   
   if (tBottom - tResultsHeight - 2) <= (50 + tHeaderHeight)
   then put (51 + tHeaderHeight) into tLineYLoc
   else put (tBottom - tResultsHeight - 1) into tLineYLoc
   
   set the loc of graphic "line" to tLineXLoc,tLineYLoc
   
   set the rect of field "script" of me to tLeft,tTop,tRight,(tLineYLoc - 1)
   set the rect of field "results" of me to tLeft,(tLineYLoc + 1),tRight,tBottom
   
   unlock screen
   unlock messages
end resizeControl
