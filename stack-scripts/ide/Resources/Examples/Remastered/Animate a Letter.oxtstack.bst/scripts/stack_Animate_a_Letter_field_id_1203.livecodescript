script "stack_Animate_a_Letter_field_id_1203"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Arrow Keys" (id 1039) > field "Letter" (id 1203)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--in msg box: set the cStartLoc of field "Letter" to the loc of field "Letter"  --created custom property of the object, cStartLoc, to store x,y location.
--card script has arrowKey message handler, hidden graphic "Boundary" provides restraint dimensions.

on mouseUp  --reset
   lock screen
   set the loc of me to the cStartLoc of me  --custom property
   set the loc of graphic "Ball" to the cStartLoc of graphic "Ball"  --its own custom property
end mouseUp
