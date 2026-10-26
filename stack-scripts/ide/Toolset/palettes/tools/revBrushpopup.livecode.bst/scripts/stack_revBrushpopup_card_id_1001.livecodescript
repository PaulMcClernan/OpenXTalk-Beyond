script "stack_revBrushpopup_card_id_1001"
-- Stack file: ide/Toolset/palettes/tools/revBrushpopup.livecode
-- Object: stack "revBrushpopup" > card "Brushes Card" (id 1001)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   set the defaultStack to "revBrushpopup"
   set the loc of grc "marquee" to the loc of btn (the cBrushShape of this stack) of group 1
end preOpenCard

on setMarqCol
   set the foregroundColor of graphic "marquee" of card 1 of stack "revBrushPopup" to the cToolSelectorColor of stack "revPreferences"
end setMarqCol

on mousemove
   set the cBrushID of this stack to the id of btn (the cBrushShape of this stack) of group 1
   pass mousemove
end mousemove

on closecard
   send reAffirmBrushChoice to stack "revTools"
end closecard
