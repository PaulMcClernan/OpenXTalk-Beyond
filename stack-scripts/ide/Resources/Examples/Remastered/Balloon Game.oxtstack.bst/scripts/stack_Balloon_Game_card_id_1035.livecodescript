script "stack_Balloon_Game_card_id_1035"
-- Stack file: ide/Resources/Examples/Remastered/Balloon Game.oxtstack
-- Object: stack "Balloon Game" > card "page4" (id 1035)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   global gName
   ## (remaster) "Congratulations," with a comma, which the original's left out
   put "Congratulations," && gName & ". You have reached the end of your balloon adventure." into field "story"
   ## (remaster) The window lays the card out after this handler: it passes the message on
   pass preOpenCard
end preOpenCard
