script "stack_Animate_Letter_button_id_1015"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1002) > group (id 1017) > button "Previous" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --previous
   visual effect wipe right
   go prev card
end mouseUp
