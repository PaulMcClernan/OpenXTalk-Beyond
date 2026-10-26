script "stack_Balloon_Game_group_id_1359"
-- Stack file: ide/Resources/Examples/Remastered/Balloon Game.oxtstack
-- Object: stack "Balloon Game" > card "Collisions" (id 1038) > group "Play Sound" (id 1359)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## (remaster) The sound the game plays when you collect points: the audioclip "hiscore.wav", which is
## in this stack
on mouseUp
   local tError
   try
      play audioclip "hiscore.wav"
   catch tError
      ## (where it cannot be played, the button says so)
      put "No sound here" into field "Play Sound_label"
   end try
end mouseUp
