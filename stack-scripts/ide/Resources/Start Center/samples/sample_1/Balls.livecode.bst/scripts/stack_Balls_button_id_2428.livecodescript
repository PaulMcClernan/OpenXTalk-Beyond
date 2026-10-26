script "stack_Balls_button_id_2428"
-- Stack file: ide/Resources/Start Center/samples/sample_1/Balls.livecode
-- Object: stack "Balls" > card "main" (id 1002) > group (id 2429) > button "Create Balls" (id 2428)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   ask "How Many Balls?"
   if it is a number then
      newBalls it
   end if
end mouseUp

on mouseDown
   
end mouseDown
