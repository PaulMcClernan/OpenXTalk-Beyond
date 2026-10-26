script "stack_Quick_Dictionary_image_id_35929"
-- Stack file: ide/Plugins/Quick Dictionary.livecode
-- Object: stack "Quick Dictionary" > card (id 1002) > image "flip-down" (id 35929)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   set the tOldTL of this wd to the topleft of this wd
   --
   lock screen
   show image "flip-up" of this card
   hide image "flip-down" of this card
   hide group "filtro" of this card
   hide btn "All" of this card
   hide btn "AutoSearch" of this card
   hide graphic "Line" of this card
   hide group "DictBtns" of this card
   set the decorations of stack "Quick Dictionary" to none
   -- pin underneath 'dictionary' button
   put the left of btn "Dictionary" of stack "Revmenubar" + the left of stack "revmenubar" + (the width of btn "Dictionary" of stack "Revmenubar" /2 )into tLeftPos
   put round(tLeftPos,0) into tLeftPos 
   put the bottom of btn "Dictionary" of stack "Revmenubar" + the top of stack "revmenubar" into tTopPos
   put tLeftPos, tTopPos into tComputedFloatPos
   send resizestack to this card
   --
   set the itemdelimiter to ","
   put the width of this stack /2 into tSubWidth
   put round(tSubwidth,0) into tSubWidth
   subtract tSubWidth from item 1 of tComputedFloatPos
   set the topleft of this wd to tComputedFloatPos
   unlock screen
end mousedown
