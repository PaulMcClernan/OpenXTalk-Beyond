script "stack_Animate_Letter_field_id_1064"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1059) > field "Score" (id 1064)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --reset
   put "0" into me
   set the loc of graphic "Ball" to the loc of this card
end mouseUp
