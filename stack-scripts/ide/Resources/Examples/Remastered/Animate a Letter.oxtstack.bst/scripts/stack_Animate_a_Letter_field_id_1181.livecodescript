script "stack_Animate_a_Letter_field_id_1181"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Change Color" (id 1031) > field "Letter2" (id 1181)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --color
   if shiftKey() = "down" then  --reset
      set the backColor of me to the cColor of me  --its first color, kept in a custom property
   else set the backColor of me to any line of colorNames()
end mouseUp
