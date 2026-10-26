script "stack_com.livecode.pi.multiplechoice_button_id_1015"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.multiplechoice.livecode
-- Object: stack "com.livecode.pi.multiplechoice" > card (id 1002) > button "group behavior" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeGroup pChoices
   set the itemdelimiter to "|"
   local tLeft, tTop
   put the left of me into tLeft
   put the top of me into tTop
   local tWidth
   put the width of me / (the number of items in pChoices + 1) into tWidth
   set the width of field "label" of me to tWidth
   set the height of field "label" of me to the formattedheight of field "label" of me
   set the topleft of field "label" of me to tLeft,tTop
   add tWidth to tLeft
   
   local tButton
   repeat for each line tChoice in pChoices
      if the number of items in tChoice is 2 then
         put item 2 of tChoice into tButton
      else
         put tChoice into tButton
      end if
      set the width of button tButton of me to tWidth
      set the topleft of button tButton of me to tLeft,tTop
      add tWidth to tLeft
   end repeat
end resizeGroup

on valueChosen
   hilite the target
   dispatch "valueChanged" with the short name of me
end valueChosen

on setEnabled pValue
   repeat for each line tLine in the childControlNames of me
      set the enabled of control tLine of me to pValue
   end repeat
end setEnabled
