script "stack_revCore_button_id_1008"
-- Stack file: ide/Toolset/palettes/revCore.8.livecode
-- Object: stack "revCore" > card (id 1002) > button "tip_display_behavior" (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on layoutTip
   local tMessageWidth,tMessageHeight
   
   set the rect of graphic "tip_background" of me to the rect of me
   
   set the height of field "tip_close" of me to the formattedHeight of field "tip_close" of me
   set the width of field "tip_close" of me to the formattedWidth of field "tip_close" of me
   
   put the width of me - the width of image "tip_icon" of me - the width of field "tip_close" - 20 into tMessageWidth
   put the height of me into tMessageHeight
   
   set the width of field "tip_message" of me to tMessageWidth
   set the height of field "tip_message" of me to the formattedHeight of field "tip_message" of me
   set the loc of field "tip_message" of me to the loc of me
   set the left of field "tip_message" of me to the right of image "tip_icon" of me
   
   set the loc of image "tip_icon" of me to (the left of me + 10 + round(the width of image "tip_icon" of me / 2)-1),the top of me + round(the height of me / 2)-1
   set the loc of field "tip_close" of me to (the right of me - 10 - round(the width of field "tip_close" of me / 2)-1),the top of me + round(the height of me / 2)
end layoutTip

on hideTip
   hide me
   dispatch "tipPreferenceSet" with "false"
   dispatch "tipDisplayUpdate"
end hideTip

on mouseUp
   launch url the cLink of me
end mouseUp

on mouseEnter
   lock cursor
   set the cursor to hand
   lock screen
   put the cToolSelectorColor of stack "revPreferences" into tDarkerHLColour
   put the itemdelimiter into tOldDelim
   set the itemdelimiter to ","
   if item 1 of tDarkerHLColour >20 then subtract 20 from item 1 of tDarkerHLColour
   if item 2 of tDarkerHLColour >20 then subtract 20 from item 2 of tDarkerHLColour
   if item 2 of tDarkerHLColour >20 then subtract 20 from item 3 of tDarkerHLColour
   set the itemdelimiter to tOldDelim
   set the backgroundColor of graphic "tip_background" of me to tDarkerHLColour -- ideCoreEditionHoverColour()
   unlock screen
end mouseEnter

on mouseLeave
   if the mouseloc is not within the rect of me then
      unlock cursor
      set the backgroundColor of graphic "tip_background" of me to the cToolSelectorColor of stack "revPreferences"-- ideCoreEditionColour()
   end if
end mouseLeave
