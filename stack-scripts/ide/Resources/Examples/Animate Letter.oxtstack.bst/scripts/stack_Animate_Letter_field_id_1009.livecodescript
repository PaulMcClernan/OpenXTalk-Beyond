script "stack_Animate_Letter_field_id_1009"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1002) > field "NavList" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --clickLine() = line x of field y
   visual effect dissolve
   go cd (word 2 of clickline() +1)
end mouseUp
