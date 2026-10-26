script "stack_Video_Player_button_id_1005"
-- Stack file: ide/Resources/Examples/Video Player.oxtstack
-- Object: stack "Video Player" > card (id 1002) > button "stop" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   set the paused of player "a" to true
end mousedown
