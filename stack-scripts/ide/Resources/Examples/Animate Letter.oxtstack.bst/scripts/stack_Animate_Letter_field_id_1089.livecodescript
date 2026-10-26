script "stack_Animate_Letter_field_id_1089"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1088) > field "Letter" (id 1089)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--in msg box: set the cStartLoc of field "Letter" to the loc of field "Letter"  --created custom property of the object, cStartLoc, to store x,y location.
--card script has arrowKey message handler, hidden graphic "Boundry" provides restraint dimensions.

on mouseUp  --reset
   lock screen
   set the loc of me to the cStartLoc of me  --custom property
   set the loc of graphic "Ball" to the cStartLoc of graphic "Ball"  --its own custom property
end mouseUp
