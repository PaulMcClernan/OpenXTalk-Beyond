script "stack_Animate_Letter_field_id_1086"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1072) > field "Letter" (id 1086)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --speak text
   get the text of fld "Balloon"
  revSpeak it
end mouseUp
