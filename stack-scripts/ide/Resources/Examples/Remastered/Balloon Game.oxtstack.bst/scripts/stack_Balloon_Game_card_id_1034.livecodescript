script "stack_Balloon_Game_card_id_1034"
-- Stack file: ide/Resources/Examples/Remastered/Balloon Game.oxtstack
-- Object: stack "Balloon Game" > card "page3" (id 1034)
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
   set the loc of image "bird1" to stageLoc(1034,380)
   set the loc of image "bird2" to stageLoc(1250,270)
   set the loc of image "bird3" to stageLoc(1490,500)
   ## (remaster) The window's list can bring you straight here: a balloon that is not on the stage
   ## starts again at the left, a step in
   if the left of image "balloon" >= the right of graphic "Stage" or the right of image "balloon" <= the left of graphic "Stage" then
      set the left of image "balloon" to the left of graphic "Stage" + stageSize(16)
   end if

   ## Put text into the field, using the gName variable to personalise the message
   ## (remaster) gName & ".": the original's && put a space before the full stop
   put "Hi again," && gName & ". For this task you have to move across the screen without colliding with any birds." into field "story"

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
      set the right of image "balloon" to the right of image "balloon" + stageSize(25)
   end if

   ## Check to see if the balloon has reached the right hand side
   if the left of image "balloon" > the right of graphic "Stage" then
      put false into sMoving
      go to next card
   end if
end arrowKey

on checkForCollision
   ## The intersect function tells you if 2 objects overlap/collide
   ## If the balloon and bird image overlap the game is over
   if intersect(image "balloon",image "bird1","pixels") or intersect(image "balloon",image "bird2","pixels") or intersect(image "balloon",image "bird3","pixels") then
      answer "Game Over"
      go to card "introduction"
   else
      send "moveForeground" to me in 50 milliseconds
   end if
end checkForCollision

on moveForeground
   local tStack
   ## There are 2 foreground images which connect together
   ## These are moved across the screen to create the illusion of movement

   ## Move the birds as if they are flying towards the left
   ## (remaster) A message sent in time may come while another window is in front: useGameStack, in
   ## the script of the stack, makes the names below this stack's, and the last line puts back the
   ## stack that was
   useGameStack
   put the result into tStack
   lock screen
   if sMoving then
      set the left of image "foreground1" to the left of image "foreground1" - stageSize(5)
      set the left of image "foreground2" to the left of image "foreground2" - stageSize(5)
      set the left of image "bird1" to the left of image "bird1" - stageSize(10)
      set the left of image "bird2" to the left of image "bird2" - stageSize(10)
      set the left of image "bird3" to the left of image "bird3" - stageSize(10)

      ## When a foreground image moves completely off screen reset it on the right
      if the right of image "foreground1" < the left of graphic "Stage" then
         set the left of image "foreground1" to the right of image "foreground2"
      end if

      if the right of image "foreground2" < the left of graphic "Stage" then
         ## (remaster) to the right of foreground1: the original put it to the right of itself, over
         ## foreground1, and after a minute a gap opened in the ground
         set the left of image "foreground2" to the right of image "foreground1"
      end if

      ## When a bird image moves completely off screen reset it on the right
      if the right of image "bird1" < the left of graphic "Stage" then
         set the loc of image "bird1" to stageLoc(1034,380)
      end if

      if the right of image "bird2" < the left of graphic "Stage" then
         set the loc of image "bird2" to stageLoc(1034,270)
      end if

      if the right of image "bird3" < the left of graphic "Stage" then
         set the loc of image "bird3" to stageLoc(1034,500)
      end if

      ## Check for collisions between the balloon and birds
      checkForCollision
   end if
   unlock screen
   set the defaultStack to tStack
end moveForeground
