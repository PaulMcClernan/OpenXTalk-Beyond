script "stack_Animate_Letter_field_id_1023"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1018) > field "Letter2" (id 1023)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --color
   if shiftKey() = "down" then  --reset
      set the backColor of me to empty  --no backColor
      set the textColor of me to empty  --default black
   else set the backColor of me to any line of colorNames()
end mouseUp
