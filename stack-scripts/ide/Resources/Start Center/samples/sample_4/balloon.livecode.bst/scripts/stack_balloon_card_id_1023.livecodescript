script "stack_balloon_card_id_1023"
-- Stack file: ide/Resources/Start Center/samples/sample_4/balloon.livecode
-- Object: stack "balloon" > card "page2" (id 1023)
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
   set the loc of image "foreground1" to 512,694
   set the topLeft of image "foreground2" to the topRight of image "foreground1"
   
   ## Set the score to 0
   put "0" into field "score"
   
   ## Put text into the field, using the gName variable to personalise the message
   put "Hi again," && gName && ". For this task you have to collect 3000 points to move on to the next level. Pilot your balloon around using the arrow keys to collect points." into field "story"
   
   ## Display points to be collected
   showPoints
   
   ## Move the foreground to give the illusion of movement
   put true into sMoving
   moveForeground
end preOpenCard

on closeCard
   put false into sMoving
end closeCard

## The arrowKey message is sent when an arrow key is pressed
## The direction is passed as a parameter
on arrowKey pDirection
   ## Depending on the direction reset the position of the balloon image
   ## Before moving the balloon check it will not go offscreen
   if pDirection is "down" then
      if the bottom of image "balloon" < (the height of this stack - 5) then
         set the bottom of image "balloon" to the bottom of image "balloon" + 25
      end if
   else if pDirection is "up" then
      if the top of image "balloon" > 5 then
         set the top of image "balloon" to the top of image "balloon" - 25
      end if
   else if pDirection is "left" then
      if the left of image "balloon" > 5 then
         set the left of image "balloon" to the left of image "balloon" - 25
      end if
   else if pDirection is "right" then
      ## When moving right allow the balloon to go offscreen if the score has reached 3000
      if (the right of image "balloon" < the width of this stack) or (field "score" >= 3000) then 
         set the right of image "balloon" to the right of image "balloon" + 25
      end if
   end if
   
   ## Check to see if the balloon has collected a score object
   if field "score" < 3000 then
      checkForScore
   else
      ## 3000 has been scored
      ## Check if player has moved off right of the screen
      if the left of image "balloon" > the width of this stack then
         put false into sMoving
         set the top of image "balloon" of card "page3" to the top of image "balloon" of this card
         set the left of image "balloon" of card "page3" to 0
         go to next card
      end if
   end if   
end arrowKey

on showPoints
   ## Use the random function to display the points image at a random point on screen
   set the loc of image "points" to random(the width of this stack),250 + random(the height of this stack-250)
end showPoints

on checkForScore
   ## The intersect function tells you if 2 objects overlap/collide
   ## If the balloon and points image overlap
   if intersect(image "balloon",image "points","pixels") then
      ## Increase the score by 1000
      add 1000 to field "score"
      ## Play a sound
      if the platform is "mobile" then
         play (specialFolderPath("engine") & "/hiscore.wav")
      else
         play audioclip "hiscore.wav"
      end if
      
      ## Check if 3000 has been reached
      if field "score" = 3000 then
         ## If so display a new message
         set the bottomRight image "points" to 0,0
         put "Congratulations. Now pilot your balloon off the right hand side of the screen." into field "story"         
      else
         ## If not reposition the score image to be collected again
         showPoints
      end if
   end if
end checkForScore

on moveForeground
   ## There are 2 foreground images which connect together
   ## These are moved across the screen to create the illusion of movement
   lock screen
   if sMoving then
      set the left of image "foreground1" to the left of image "foreground1" - 5
      set the left of image "foreground2" to the left of image "foreground2" - 5
      
      ## When a foreground image moves completely off screen reset it on the right
      if the right of image "foreground1" < 0 then 
         set the left of image "foreground1" to the right of image "foreground2"
      end if
      
      if the right of image "foreground2" < 0 then 
         set the left of image "foreground2" to the right of image "foreground2"
      end if
      send "moveForeground" to me in 50 milliseconds
   end if
   unlock screen
end moveForeground
