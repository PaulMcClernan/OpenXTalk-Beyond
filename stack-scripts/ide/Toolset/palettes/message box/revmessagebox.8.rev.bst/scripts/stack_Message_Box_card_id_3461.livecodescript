script "stack_Message_Box_card_id_3461"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Front Scripts" (id 3461)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sDataA

on preOpenCard
   lock screen
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
end closeCard

on resizeStack
   set the rect of group "objectList" of this card to the contentRect of me
   pass resizeStack
end resizeStack

command getDataArray
   local tShow, tFilteredFrontScripts, tFrontScripts, tDisplay, tLine, tCount, tFrontScript, tScriptLines
   
   put revIDEGetPreference("cShowRevolutionStacks") into tShow
   if tShow is true then
      put the frontScripts into tFilteredFrontScripts
   else
      put the frontScripts into tFrontScripts
      put empty into tFilteredFrontScripts
      set the itemdel to slash
      repeat for each line tLine in tFrontScripts
         if char 1 to 3 of the last item of tLine is not "rev" then put tLine & return after tFilteredFrontScripts
      end repeat
   end if
   
   repeat for each line tLine in tFilteredFrontScripts
      put the name of tLine & return after tDisplay
   end repeat
   delete last char of tDisplay
   set the cREVFrontScripts of this stack to tFilteredFrontScripts
   
   put 0 into tCount
   repeat for each line l in tDisplay
      add 1 to tCount
      put l into sDataA[tCount]["front script"]
      
      --setting up an array with all the data and not just control names
      put line tCount of the cREVFrontScripts of this stack into tFrontScript
      put tFrontScript into sDataA[tCount]["long id"]
      
      put revIDEObjectScriptLines(tFrontScript) into tScriptLines
      if tScriptLines is empty
      then put 0 into sDataA[tCount]["script lines"]
      else put tScriptLines into sDataA[tCount]["script lines"]
      
      if the behavior of tFrontScript is empty
      then put "-" into sDataA[tCount]["behavior lines"]
      else put revIDEObjectScriptLines(the behavior of tFrontScript) into sDataA[tCount]["behavior lines"]
   end repeat
   
   if tDisplay is empty then 
      disableFrameItem "removeAll"
      show field "status"
   else 
      enableFrameItem "removeAll"
      hide field "status"
   end if
end getDataArray

function NumberOfRows
   return the number of lines of the cREVFrontScripts of this stack
end NumberOfRows

command DataForRow pRow, @pDataA, @pTemplateStyle
   local tData1, tData2, tData3, tData4
   
   put sDataA[pRow]["front script"] into tData1
   put sDataA[pRow]["long id"] into tData2
   put sDataA[pRow]["script lines"] into tData3
   put sDataA[pRow]["behavior lines"] into tData4
   
   put tData1,tData2,tData3,tData4 into pDataA
   put "frontScripts" into pTemplateStyle
end DataForRow
