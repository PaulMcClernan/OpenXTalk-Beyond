script "stack_Animate_a_Letter_field_id_1183"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Move Around" (id 1032) > field "Letter2" (id 1183)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --move me
   local tStartLoc
   --set the visible of graphic "Curve1" to not the visible of graphic "Curve1"  --hide/show
   put the loc of me into tStartLoc  --starting point
   move me to the points of graphic "Curve1"  --move along a curve graphic (its dashed line)
   wait .5 sec with messages  --optional
   move me from the loc of me to tStartLoc  --move back
end mouseUp
