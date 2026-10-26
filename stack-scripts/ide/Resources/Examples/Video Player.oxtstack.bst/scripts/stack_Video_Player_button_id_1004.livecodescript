script "stack_Video_Player_button_id_1004"
-- Stack file: ide/Resources/Examples/Video Player.oxtstack
-- Object: stack "Video Player" > card (id 1002) > button "play" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   set the paused of player "a" to false
end mousedown
