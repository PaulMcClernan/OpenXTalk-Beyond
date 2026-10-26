script "stack_Message_Box_button_id_26750"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "templates" (id 10773) > button "frontScriptsRow Behavior" (id 26750)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lIcon,lRow

on FillInData pDataA, pRow
   local tFrontScript, tScriptLines
   
   put item 1 of pDataA into field "control name" of me
   
   hide image "stack.png" of me
   hide image "button.png" of me
   hide image "group.png" of me
   hide image "card.png" of me
   hide image "graphic.png" of me
   hide image "image.png" of me
   hide image "field.png" of me
   hide image "substack.png" of me

   put item 2 of pDataA into field "long id" of me
   put item 3 of pDataA into field "scriptLines" of me
   
   put item 4 of pDataA into tBehavior
   if tBehavior is "-" then hide field "behaviorScriptLines" of me
   else 
      show field "behaviorScriptLines" of me 
      put tBehavior into field "behaviorScriptLines" of me
   end if
   
   put the first word of item 1 of pDataA & ".png" into lIcon
end FillInData

on LayoutControl pControlRect
   local tMargin, tPadding, tLoc
   
   put the paletteMargin of me into tMargin
   put the palettePadding of me into tPadding
   
   set the rect of graphic "background" of me to pControlRect
   
   show image lIcon of me
   
   set the width of image lIcon of me to the formattedWidth of control lIcon of me
   set the width of field "control name" of me to the formattedWidth of field "control name" of me
   set the width of field "scriptLines" of me to the formattedWidth of field "scriptLines" of me
   set the width of field "behaviorScriptLines" of me to the formattedWidth of field "behaviorScriptLines" of me
   set the width of button "remove selected" of me to the formattedWidth of button "remove selected" of me
   
   put the loc of me into tLoc
   put item 1 of pControlRect + 20 into item 1 of tLoc
   set the loc of control lIcon of me to tLoc
   
   set the loc of field "control name" of me to tLoc
   set the loc of button "remove selected" of me to tLoc
   set the loc of field "scriptLines" of me to tLoc
   set the loc of field "behaviorScriptLines" of me to tLoc
   
   set the left of field "control name" of me to item 1 of tLoc + tMargin
   set the right of button "remove selected" of me to item 3 of pControlRect - tMargin
   set the right of field "scriptLines" of me to the left of button "remove selected" - the tPadding of me
   set the right of field "behaviorScriptLines" of me to the left of field "scriptLines" of me - 2
end LayoutControl

getProp dvRowControl
   return the long id of me
end dvRowControl

setProp dvHilite[pHiliteColor] pBoolean
   if pBoolean then
      set the foregroundColor of field "control name" of me to  revIDEColor("text_3")
      set the foregroundColor of field "scriptLines" of me to  revIDEColor("text_1")
      set the foregroundColor of field "behaviorScriptLines" of me to revIDEColor("text_1")
      
      set the backgroundColor of field "scriptLines" of me to  revIDEColor("dataView_TextHiliteColor")
      set the backgroundColor of field "behaviorScriptLines" of me to  revIDEColor("dataView_TextHiliteColor")
      
      set the colorOverlay["color"] of image lIcon of me to revIDEColor("dataView_TextHiliteColor")
   else
      set the foregroundColor of field "control name" of me to revIDEColor("text_1")
      set the foregroundColor of field "scriptLines" of me to  revIDEColor("text_3")
      set the foregroundColor of field "behaviorScriptLines" of me to  revIDEColor("text_3")
      
      set the backgroundColor of field "scriptLines" of me to revIDEColor("dataView_hiliteColor")
      set the backgroundColor of field "behaviorScriptLines" of me to revIDEColor("dataView_hiliteColor")
      
      set the colorOverlay of image lIcon of me to empty
   end if
end dvHilite

on mouseUp
   scriptAction (the text of field "long id" of me), (the text of field "control name" of me)
end mouseUp
