script "stack_Animate_a_Letter_field_id_1197"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Speak" (id 1038) > field "Letter" (id 1197)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --speak text
   get the text of fld "Balloon"
   revSpeak it
end mouseUp
