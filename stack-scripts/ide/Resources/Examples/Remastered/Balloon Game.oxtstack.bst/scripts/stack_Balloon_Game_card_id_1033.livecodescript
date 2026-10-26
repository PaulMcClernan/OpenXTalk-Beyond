script "stack_Balloon_Game_card_id_1033"
-- Stack file: ide/Resources/Examples/Remastered/Balloon Game.oxtstack
-- Object: stack "Balloon Game" > card "page2" (id 1033)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## The preOpenCard message is sent before the card is made visible to the user
## Any layout can be done here and will not be visible

## Use a script local variable to store whether the foreground should move
local sMoving

on preOpenCard
   ## Declare the global variable so it can be used
   global gName

   ## Reposition the controls
   ## (remaster) on the stage: stageLoc is in the script of the stack
   set the loc of image "foreground1" to stageLoc(512,694)
   set the topLeft of image "foreground2" to the topRight of image "foreground1"
   ## (remaster) The window's list can bring you straight here: a balloon that is not on the stage
   ## (it flew off to the right last time) starts again at the left, a step in
   if the left of image "balloon" >= the right of graphic "Stage" or the right of image "balloon" <= the left of graphic "Stage" then
      set the left of image "balloon" to the left of graphic "Stage" + stageSize(16)
   end if

   ## Set the score to 0
   put "0" into field "score"

   ## Put text into the field, using the gName variable to personalise the message
   ## (remaster) gName & ".": the original's && put a space before the full stop
   put "Hi again," && gName & ". For this task you have to collect 3000 points to move on to the next level. Pilot your balloon around using the arrow keys to collect points." into field "story"

   ## Display points to be collected
   showPoints

   ## Move the foreground to give the illusion of movement
   put true into sMoving
   moveForeground
   ## (remaster) The window lays the card out after this handler: it passes the message on
   pass preOpenCard
end preOpenCard

on closeCard
   put false into sMoving
end closeCard

## The arrowKey message is sent when an arrow key is pressed
## The direction is passed as a parameter
## (remaster) The edges are the stage's, and the steps are the original's, made smaller as the game
## is: stageSize(25) is 18 pixels
on arrowKey pDirection
   ## Depending on the direction reset the position of the balloon image
   ## Before moving the balloon check it will not go offscreen
   if pDirection is "down" then
      if the bottom of image "balloon" < (the bottom of graphic "Stage" - stageSize(5)) then
         set the bottom of image "balloon" to the bottom of image "balloon" + stageSize(25)
      end if
   else if pDirection is "up" then
      if the top of image "balloon" > the top of graphic "Stage" + stageSize(5) then
         set the top of image "balloon" to the top of image "balloon" - stageSize(25)
      end if
   else if pDirection is "left" then
      if the left of image "balloon" > the left of graphic "Stage" + stageSize(5) then
         set the left of image "balloon" to the left of image "balloon" - stageSize(25)
      end if
   else if pDirection is "right" then
      ## When moving right allow the balloon to go offscreen if the score has reached 3000
      if (the right of image "balloon" < the right of graphic "Stage") or (field "score" >= 3000) then
         set the right of image "balloon" to the right of image "balloon" + stageSize(25)
      end if
   end if

   ## Check to see if the balloon has collected a score object
   if field "score" < 3000 then
      checkForScore
   else
      ## 3000 has been scored
      ## Check if player has moved off right of the screen
      if the left of image "balloon" > the right of graphic "Stage" then
         put false into sMoving
         set the top of image "balloon" of card "page3" to the top of image "balloon" of this card
         ## (remaster) a step in from the left of the stage, as on this card
         set the left of image "balloon" of card "page3" to the left of graphic "Stage" + stageSize(16)
         go to next card
      end if
   end if
end arrowKey

on showPoints
   ## Use the random function to display the points image at a random point on screen
   ## (remaster) a random place on the original's card, 1024 by 768, on the stage
   set the loc of image "points" to stageLoc(random(1024), 250 + random(768 - 250))
end showPoints

on checkForScore
   local tError
   ## The intersect function tells you if 2 objects overlap/collide
   ## If the balloon and points image overlap
   if intersect(image "balloon",image "points","pixels") then
      ## Increase the score by 1000
      add 1000 to field "score"
      ## Play a sound
      ## (remaster) The original asked whether the platform was "mobile", which it never is (a phone's
      ## is "iphone" or "android"): on a phone, the environment is "mobile". A computer that cannot
      ## play the sound (a browser may not) plays on without it
      try
         if the environment is "mobile" then
            play (specialFolderPath("engine") & "/hiscore.wav")
         else
            play audioclip "hiscore.wav"
         end if
      catch tError
      end try

      ## Check if 3000 has been reached
      if field "score" = 3000 then
         ## If so display a new message
         ## (remaster) off the stage, at its top left: the original's was 0,0, its card's top left
         set the bottomRight image "points" to the topLeft of graphic "Stage"
         put "Congratulations. Now pilot your balloon off the right hand side of the screen." into field "story"
      else
         ## If not reposition the score image to be collected again
         showPoints
      end if
   end if
end checkForScore

on moveForeground
   local tStack
   ## There are 2 foreground images which connect together
   ## These are moved across the screen to create the illusion of movement
   ## (remaster) A message sent in time may come while another window is in front: useGameStack, in
   ## the script of the stack, makes the names below this stack's, and the last line puts back the
   ## stack that was
   useGameStack
   put the result into tStack
   lock screen
   if sMoving then
      set the left of image "foreground1" to the left of image "foreground1" - stageSize(5)
      set the left of image "foreground2" to the left of image "foreground2" - stageSize(5)

      ## When a foreground image moves completely off screen reset it on the right
      if the right of image "foreground1" < the left of graphic "Stage" then
         set the left of image "foreground1" to the right of image "foreground2"
      end if

      if the right of image "foreground2" < the left of graphic "Stage" then
         ## (remaster) to the right of foreground1: the original put it to the right of itself, over
         ## foreground1, and after a minute a gap opened in the ground
         set the left of image "foreground2" to the right of image "foreground1"
      end if
      send "moveForeground" to me in 50 milliseconds
   end if
   unlock screen
   set the defaultStack to tStack
end moveForeground
