script "stack_Message_Box_button_id_29633"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "templates" (id 10773) > button "pendingMessagesRow Behavior" (id 29633)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on FillInData pDataA, pRow
   local tScriptLines, tObject
   
   put pDataA into field "message" of me
   put item 4 of pDataA into tObject
   if  (tObject begins with "stack" and the password of tObject is true) then
      put 0 into tScriptLines
   else
      put the number of lines of the script of tObject into tScriptLines
   end if
   
   if tScriptLines is 0 or tScriptLines is empty 
   then put 0 into field "scriptLines" of me
   else put tScriptLines into field "scriptLines" of me
   
   if the behavior of (item 4 of pDataA) is not empty then
      show field "behaviorScriptLines" of me
      put the number of lines of the script of the behavior of (item 4 of pDataA) into field "behaviorScriptLines" of me
   else 
      hide field "behaviorScriptLines" of me 
      put "-" into field "behaviorScriptLines" of me
   end if
end FillInData

on LayoutControl pControlRect
   local tMargin, tPadding, tWidth, tLoc
   
   put the paletteMargin of me into tMargin
   put the palettePadding of me into tPadding
   
   set the rect of graphic "background" of me to pControlRect
   
   set the width of field "scriptLines" of me to the formattedWidth of field "scriptLines" of me
   set the width of field "behaviorScriptLines" of me to the formattedWidth of field "behaviorScriptLines" of me
   set the width of button "remove selected" of me to the formattedWidth of button "remove selected" of me
   
   put (2*(tMargin + tPadding) + the width of button "remove selected" + the width of field "scriptLines") into tWidth
   if the text of field "behaviorScriptLines" is "-"
   then set the width of field "message" to (the width of graphic "background" - tWidth)
   else set the width of field "message" to (the width of graphic "background" - the width of field "behaviorScriptLines" - tPadding - tWidth)
   
   put the loc of me into tLoc
   put item 1 of pControlRect into item 1 of tLoc
   
   set the loc of field "message" of me to tLoc
   set the loc of button "remove selected" of me to tLoc
   set the loc of field "scriptLines" of me to tLoc
   set the loc of field "behaviorScriptLines" of me to tLoc
   
   set the left of field "message" of me to item 1 of pControlRect
   set the right of button "remove selected" of me to item 3 of pControlRect - tMargin
   set the right of field "scriptLines" of me to the left of button "remove selected" of me - tPadding
   set the right of field "behaviorScriptLines" of me to the left of field "scriptLines" of me - tPadding
end LayoutControl

getProp dvRowControl
   return the long id of me
end dvRowControl

setProp dvHilite[pHiliteColor] pBoolean
   if pBoolean then
      set the foregroundColor of field "message" of me to  revIDEColor("text_3")
      set the foregroundColor of field "scriptLines" of me to  revIDEColor("text_1")
      set the foregroundColor of field "behaviorScriptLines" of me to revIDEColor("text_1")
      
      set the backgroundColor of field "scriptLines" of me to  revIDEColor("dataView_TextHiliteColor")
      set the backgroundColor of field "behaviorScriptLines" of me to  revIDEColor("dataView_TextHiliteColor")
   else
      set the foregroundColor of field "message" of me to revIDEColor("text_1")
      set the foregroundColor of field "scriptLines" of me to  revIDEColor("text_3")
      set the foregroundColor of field "behaviorScriptLines" of me to  revIDEColor("text_3")
      
      set the backgroundColor of field "scriptLines" of me to revIDEColor("dataView_hiliteColor")
      set the backgroundColor of field "behaviorScriptLines" of me to revIDEColor("dataView_hiliteColor")
   end if
end dvHilite

on mouseUp
   switch the short name of the target
      case "scriptLines"
         local tMessage
         put the text of field "message" into tMessage
         edit the script of (item 4 of tMessage)
         break
      case "behaviorScriptLines"
         edit the script of the behavior of (item 4 of the text of field "message")
         break
      case "remove selected"
         cancel item 1 of the text of field "message"
         revIDEPendingMessagesRefresh
         break
      default
         pass mouseUp
   end switch
end mouseUp
