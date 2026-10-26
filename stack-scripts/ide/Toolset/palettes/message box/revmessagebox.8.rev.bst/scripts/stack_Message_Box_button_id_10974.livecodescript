script "stack_Message_Box_button_id_10974"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "templates" (id 10773) > button "stacksRow Behavior Script" (id 10974)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on FillInData pDataA, pRow
   local tScriptLines
   
   put pDataA["library stack"] into field "stack name" of me
   
   put pDataA["script lines"] into tScriptLines
   if tScriptLines is empty 
   then put 0 into field "scriptLines" of me
   else put tScriptLines into field "scriptLines" of me
   
   if pDataA["behavior script lines"] is not "-" then
      show field "behaviorScriptLines" of me
      put pDataA["behavior script lines"] into field "behaviorScriptLines" of me
   else 
      hide field "behaviorScriptLines" of me 
      put "-" into field "behaviorScriptLines" of me
   end if
end FillInData

on LayoutControl pControlRect
   local tMargin, tPadding, tLoc, tLoc1, tLoc2
   
   put the paletteMargin of me into tMargin
   put the palettePadding of me into tPadding
   
   set the rect of graphic "background" of me to pControlRect
   
   set the width of field "stack name" of me to the formattedWidth of field "stack name" of me
   set the width of field "scriptLines" of me to the formattedWidth of field "scriptLines" of me
   set the width of field "behaviorScriptLines" of me to the formattedWidth of field "behaviorScriptLines" of me
   set the width of button "remove selected" of me to the formattedWidth of button "remove selected" of me
   
   put the loc of me into tLoc
   put item 1 of pControlRect + 20 into item 1 of tLoc
   set the loc of image "stack.png" of me to tLoc
   
   set the loc of field "stack name" of me to tLoc
   set the loc of button "remove selected" of me to tLoc
   set the loc of field "scriptLines" of me to tLoc
   set the loc of field "behaviorScriptLines" of me to tLoc
   
   set the left of field "stack name" of me to item 1 of tLoc + tMargin
   set the right of button "remove selected" of me to item 3 of pControlRect - tMargin
   set the right of field "scriptLines" of me to the left of button "remove selected" - the tPadding of me
   set the right of field "behaviorScriptLines" of me to the left of field "scriptLines" of me - 2
end LayoutControl

getProp dvRowControl
   return the long id of me
end dvRowControl

setProp dvHilite[pHiliteColor] pBoolean
   if pBoolean then
      set the foregroundColor of field "stack name" of me to  revIDEColor("text_3")
      set the foregroundColor of field "scriptLines" of me to  revIDEColor("text_1")
      set the foregroundColor of field "behaviorScriptLines" of me to revIDEColor("text_1")
      
      set the backgroundColor of field "scriptLines" of me to  revIDEColor("dataView_TextHiliteColor")
      set the backgroundColor of field "behaviorScriptLines" of me to  revIDEColor("dataView_TextHiliteColor")
      
      set the colorOverlay["color"] of image "stack.png" of me to revIDEColor("dataView_TextHiliteColor")
   else
      set the foregroundColor of field "stack name" of me to revIDEColor("text_1")
      set the foregroundColor of field "scriptLines" of me to  revIDEColor("text_3")
      set the foregroundColor of field "behaviorScriptLines" of me to  revIDEColor("text_3")
      
      set the backgroundColor of field "scriptLines" of me to revIDEColor("dataView_hiliteColor")
      set the backgroundColor of field "behaviorScriptLines" of me to revIDEColor("dataView_hiliteColor")
      
      set the colorOverlay of image "stack.png" of me to empty
   end if
end dvHilite

on mouseUp
   switch the short name of the target
      case "scriptLines"
         edit the script of stack (the text of field "stack name" of me)
         break
      case "behaviorScriptLines"
         edit the script of the behavior of stack (the text of field "stack name" of me)
         break
      case "remove selected"
         stop using stack (the text of field "stack name" of me)
         revIDEUpdateStacksInUse
         break
      default
         pass mouseUp
   end switch
end mouseUp
