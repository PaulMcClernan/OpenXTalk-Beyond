script "stack_Message_Box_card_id_2526"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Global Variables" (id 2526)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   lock screen
   showFrameItem "removeSelected"
   showFrameItem "newGlobalVariable"
   
   put empty into field "filter"
   focus field "filter"
   
   revIDEUpdateGlobalVariables
   
   set the hilitedLine of field "type" to the cREVHilitedVariable of field "type"
   if the hilitedLine of field "type" is empty 
   then disableFrameItem "removeSelected"
   else enableFrameItem "removeSelected"
   send "revDisplayGlobals" to field "type"
   
   send "resizeStack" to me
   unlock screen
end preOpenCard

on closeCard
   hideFrameItem "removeSelected"
   hideFrameItem "newGlobalVariable"
end closeCard

on resizeStack
   set the rect of group "controls" of this card to the contentRect of me
   pass resizeStack
end resizeStack
