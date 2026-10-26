script "stack_Animate_a_Letter_field_id_1195"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Keep Score" (id 1037) > field "Score" (id 1195)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --reset
   put "0" into me
   set the loc of graphic "Ball" to the loc of graphic "Stage"
end mouseUp
