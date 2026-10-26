script "stack_Message_Box_card_id_9525"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Stacks in Use" (id 9525)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sDataA

on preOpenCard
   lock screen
   showFrameItem "addStack"
   showFrameItem "removeAll"
   
   setUpDataView
   getDataArray
   
   send "renderView" to group "objectList" of this card
   
   send tUpdMBTheme(the id of this card) to this stack -- update the theming for the message box (tperry 21-4-24)
   
   send "resizeStack" to me
   unlock screen
end preOpenCard

on closeCard
   hideFrameItem "removeAll"
   hideFrameItem "addStack"
end closeCard

on resizeStack
   set the rect of group "objectList" to the contentRect of me
   pass resizeStack
end resizeStack

command getDataArray
   local tCount
   
   put 0 into tCount
   repeat for each line tLibrary in the stacksInUse
      add 1 to tCount
      put the name of stack tLibrary into sDataA[tCount]["library stack"]
      
      put the long id of stack tLibrary into sDataA[tCount]["long id"]
      
      put revIDEObjectScriptLines(the long name of stack tLibrary) into tScriptLines
      if tScriptLines is empty
      then put 0 into sDataA[tCount]["script lines"]
      else put tScriptLines into sDataA[tCount]["script lines"]
      
      if the behavior of stack tLibrary is empty
      then put "-" into sDataA[tCount]["behavior script lines"]
      else put revIDEObjectScriptLines(the behavior of stack tLibrary) into sDataA[tCount]["behavior lines"]
   end repeat
   
   if the stacksInUse is empty then 
      disableFrameItem "removeAll"
      show field "status"
   else 
      enableFrameItem "removeAll"
      hide field "status"
   end if
end getDataArray

function NumberOfRows
   return the number of lines of the stacksInUse
end NumberOfRows

command DataForRow pRow, @pDataA, @pTemplateStyle
   put sDataA[pRow] into pDataA
   put "stacksInUse" into pTemplateStyle
end DataForRow
