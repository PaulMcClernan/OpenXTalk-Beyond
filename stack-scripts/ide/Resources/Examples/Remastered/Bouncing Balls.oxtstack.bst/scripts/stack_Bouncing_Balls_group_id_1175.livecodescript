script "stack_Bouncing_Balls_group_id_1175"
-- Stack file: ide/Resources/Examples/Remastered/Bouncing Balls.oxtstack
-- Object: stack "Bouncing Balls" > card "Main" (id 1031) > group "Create Balls" (id 1175)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   ask "How Many Balls?" with 10  --(remaster) with a number to start from
   if it is a number then
      newBalls it
      ## (remaster) New balls start in one place and would fall as one: a shake, as when the card opens,
      ## sends them their own ways
      send "shakeBalls" to this card in 200 milliseconds
   end if
end mouseUp

on mouseDown

end mouseDown
