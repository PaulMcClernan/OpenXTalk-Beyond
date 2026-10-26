script "stack_Bouncing_Balls_button_id_1172"
-- Stack file: ide/Resources/Examples/Remastered/Bouncing Balls.oxtstack
-- Object: stack "Bouncing Balls" > card "Main" (id 1031) > button "bounce" (id 1172)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

############################################
## Constants
############################################

constant kGravityEffect  = 1      -- how many units the ball's y vector component will gain per frame because of gravity
constant kBounceEffect   = 2      -- how many units the ball's vector will lose if it hits the edge of the stage
constant kFrictionEffect = 0.01   -- how many units the ball's x vector component will lose per frame because of friction

############################################
## Variables
############################################

local sVector               -- vector defining the ball's current motion
local sDragging             -- if we are currently dragging the ball
local sLastDragLoc          -- the last location of the ball by way of a drag
local sCurrentDragLoc       -- the next location of the ball by way of a drag

############################################
## Properties
############################################

## Get and set the ball's vector.

## The ball's vector defines the x and y components of its motion.  For example
## a vector of -5,10 means that in a frame it will move 5 pixels left and 10
## pixels down.

getProp uVector
   return sVector
end uVector

setProp uVector pX, pY
   put (pX,pY) into sVector
end uVector

local sWidth, sHeight
## (remaster) The edges the ball bounces off: the court's, the dark part of the stage. The original's
## were the card's: local sCardWidth, sCardHeight, with 0 for its top and left
local sLeft, sTop, sRight, sBottom

on init
   put the width of me into sWidth
   put the height of me into sHeight
   put the left of graphic "Court" into sLeft
   put the top of graphic "Court" into sTop
   put the right of graphic "Court" into sRight
   put the bottom of graphic "Court" into sBottom
end init

############################################
## Main bounce routine
############################################

on bounceBall
   ## If the user is dragging the ball, move the ball to the location of the user's
   ## mouse (or finger) and don't perform any bounce calculations.

   if sDragging and sCurrentDragLoc is not empty then
      set the loc of me to sCurrentDragLoc
      exit bounceBall
   end if

   ## Work out the ball's next y location.  Add the y component of the vector to
   ## the ball's y location (we use the top).  If the ball is touching the top or
   ## the bottom of the stage, reverse the direction of the ball (multiply the
   ## y component of the vector by -1) and remove kBounceEffect units.

   ## If it is mid air, just add the effects of gravity.

   local tTop
   put the top of me + item 2 of sVector into tTop
   if tTop < sTop then
      put sTop into tTop
      put max(0, -1 * item 2 of sVector  - kBounceEffect) into item 2 sVector
   else if sHeight + tTop > sBottom then
      put sBottom - sHeight into tTop
      put min(0, -1 * item 2 of  sVector + kBounceEffect) into item 2 sVector
   else
      add kGravityEffect to item 2 of sVector
   end if

   ## Do the same for the x location (we use the left), checking to see if the
   ## ball is touching the sides.  This time, instead of gravity, we take into account
   ## friction.  Unlike gravity, friction isn't in a constant direction.  Instead,
   ## it applies in the opposite direction the ball is travelling.

   local tLeft
   put the left of me + item 1 of sVector into tLeft
   if tLeft < sLeft then
      put sLeft into tLeft
      put max(0, -1 * item 1 of sVector  - kBounceEffect) into item 1 sVector
   else if tLeft + sWidth > sRight then
      put sRight  - sWidth into tLeft
      put min(0, -1 * item 1 of sVector  + kBounceEffect) into item 1 sVector
   else
      if item 1 of sVector > 0 then
         subtract kFrictionEffect from item 1 of sVector
      else if item 1 of sVector < 0 then
         add kFrictionEffect to item 1 of sVector
      end if
   end if

   ## We now know the ball's new location.
   set the topLeft of me to (tLeft,tTop)
end bounceBall

############################################
## Drag handling
############################################

## The user has clicked, flag that we are dragging, stopping all bounce
## activity in the main loop.
on mouseDown
   put empty into sCurrentDragLoc
   put empty into sLastDragLoc
   put true into sDragging
   set the layer of me to top
end mouseDown

## The user want to move the ball, so store its new location, to be updated in
## the main bounce loop.

## Updating the ball's location in the main bounce loop means that all redraws
## are carried out in the single location (within a lock screen).

on mouseMove pX, pY
   if sDragging and (pX,pY) is not sCurrentDragLoc then
      ## (remaster) The pointer may go past the stage: the ball stops at its edges
      put max(sLeft + sWidth div 2, min(sRight - sWidth + sWidth div 2, pX)) into pX
      put max(sTop + sHeight div 2, min(sBottom - sHeight + sHeight div 2, pY)) into pY
      put sCurrentDragLoc into sLastDragLoc
      put (pX,pY) into sCurrentDragLoc
   end if
end mouseMove

## The user has released.  Launch the ball based on the amount the ball last moved.
## Do this by setting the x and y components of the ball's vector based on how much the user
## has moved the ball in the x and y directions.

## Not very smart.  Should really use a time based system.
on mouseUp
   ## (remaster) After a single move, the last place is the place it started from: the
   ## original threw the ball as far as the pointer was from the card's top left
   if sLastDragLoc is empty then
      put sCurrentDragLoc into sLastDragLoc
   end if
   put (item 1 of sCurrentDragLoc - item 1 of sLastDragLoc, item 2 of sCurrentDragLoc - item 2 of sLastDragLoc) into sVector
   put false into sDragging
end mouseUp

on mouseRelease
   mouseUp
end mouseRelease

############################################
## Drag handling for mobile (including multitouch)
############################################

## Just map touch events to their matching mouse events.  This allows for multi-touch
## handling, allowing the users to drag and throw more than one ball.
on touchStart
   mouseDown
end touchStart

on touchMove pID, pX, pY
   mouseMove pX, pY
end touchMove

on touchEnd
   mouseUp
end touchEnd

on touchRelease
   mouseUp
end touchRelease
