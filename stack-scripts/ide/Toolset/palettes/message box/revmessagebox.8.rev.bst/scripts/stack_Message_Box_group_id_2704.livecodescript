script "stack_Message_Box_group_id_2704"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Global Variables" (id 2526) > group "controls" (id 2704)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeControl
   local tLeft, tTop, tRight, tBottom
   
   lock messages
   lock screen
   
   put the left of me into tLeft
   put the top of me into tTop
   put the right of me into tRight
   put the bottom of me into tBottom
   
   set the rect of field "type" to tLeft,(tTop + 30),(tLeft + 200),tBottom
   set the rect of field "contents" to (tLeft + 200), (tTop + 30), tRight, tBottom
   set the rect of field "filter label" to tLeft,(tTop + 5),(tLeft + 50),(tTop + 25)
   set the rect of field "filter" to (tLeft + 45),(tTop + 5),(tLeft + 165),(tTop + 25)
   
   unlock screen
   unlock messages
end resizeControl
