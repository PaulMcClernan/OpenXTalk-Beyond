script "stack_Balloon_Game_card_id_1032"
-- Stack file: ide/Resources/Examples/Remastered/Balloon Game.oxtstack
-- Object: stack "Balloon Game" > card "page1" (id 1032)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## The preOpenCard message is sent before the card is made visible to the user
## Any layout can be done here and will not be visible
on preOpenCard
   ## Declare the global variable so it can be used
   global gName

   ## Reposition the controls
   ## (remaster) on the stage: stageLoc is in the script of the stack
   set the loc of image "balloon" to stageLoc(85,655)
   set the loc of image "foreground" to stageLoc(512,694)

   ## Put text into the field, using the gName variable to personalise the message
   put "Hi," && gName & ". Your hot air balloon is about to take off on a round the world adventure." & return & return & \
         "Click on the balloon to take off." into field "story"
   ## (remaster) The window lays the card out after this handler: it passes the message on
   pass preOpenCard
end preOpenCard

## (remaster) Leaving the card stops the balloon, or at the end of its path it would take you to the
## next card from wherever you went
on closeCard
   stop moving image "balloon"
end closeCard
