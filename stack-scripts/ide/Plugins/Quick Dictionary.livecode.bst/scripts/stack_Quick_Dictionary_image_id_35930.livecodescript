script "stack_Quick_Dictionary_image_id_35930"
-- Stack file: ide/Plugins/Quick Dictionary.livecode
-- Object: stack "Quick Dictionary" > card (id 1002) > image "flip-up" (id 35930)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put the prevRect of this wd into tOldRect
   set the rect of this wd to tOldRect
   --
   lock screen
   hide image "flip-up" of this card
   show image "flip-down" of this card
   show group "filtro" of this card
   show btn "All" of this card
   show btn "AutoSearch" of this card
   show graphic "Line" of this card
   show group "DictBtns" of this card
   set the decorations of stack "Quick Dictionary" to default
   send resizestack to this card
   --
   unlock screen
end mousedown
