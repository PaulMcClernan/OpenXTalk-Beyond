script "stack_Message_Box_card_id_2960"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Pending Messages" (id 2960)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sDataA, lCount

on preOpenCard
   lock screen
   showFrameItem "cancelAll"
   showFrameItem "update"
   
   setUpDataView
   getDataArray
   send "renderView" to group "objectList" of this card
   
   send tUpdMBTheme(the id of this card) to this stack -- update the theming for the message box (tperry 21-4-24)
   
   revAutoRefresh
   
   send "resizeStack" to me
end preOpenCard

on closeCard
   --cancel the Auto-refreshing
   cancel the cREVRefreshTimerID of me
 
   hideFrameItem "update"
   hideFrameItem "cancelAll"
   unlock screen
end closeCard

on resizeStack
   set the rect of group "objectList" of this card to the contentRect of me
   pass resizeStack
end resizeStack

command revAutoRefresh
   if revIDEGetPreference("ideMessageBox_autoupdate") is true then
      getDataArray
      send "renderView" to group "objectList" of this card
      send "revAutoRefresh" to me in 200 milliseconds
      set the cREVRefreshTimerID of me to the result
   end if
end revAutoRefresh

command getDataArray
   local tShow, tFilteredMessages, tPendingMessages
   
   put revIDEGetPreference("cShowRevolutionStacks") into tShow
   if tShow is true then
      put the pendingMessages into tFilteredMessages
   else
      put the pendingMessages into tPendingMessages
      put empty into tFilteredMessages
      set the itemdel to slash
      repeat for each line tLine in tPendingMessages
         if char 1 to 3 of the last item of tLine is not "rev" then put tLine & return after tFilteredMessages
      end repeat
      delete last char of tFilteredMessages
   end if
   
   set the cREVPendingMessages of this stack to tFilteredMessages
   
   put 0 into lCount
   repeat for each line l in tFilteredMessages
      add 1 to lCount
      put l into sDataA[lCount]
   end repeat
   
   if tFilteredMessages is empty then 
      disableFrameItem "cancelAll"
      show field "status"
   else 
      enableFrameItem "cancelAll"
      hide field "status"
   end if
end getDataArray

function NumberOfRows
   return lCount
end NumberOfRows

command DataForRow pRow, @pDataA, @pTemplateStyle
   put sDataA[pRow] into pDataA
   put "pendingMessages" into pTemplateStyle
end DataForRow
