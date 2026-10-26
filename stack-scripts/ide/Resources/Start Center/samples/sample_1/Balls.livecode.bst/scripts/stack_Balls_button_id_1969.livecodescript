script "stack_Balls_button_id_1969"
-- Stack file: ide/Resources/Start Center/samples/sample_1/Balls.livecode
-- Object: stack "Balls" > card "main" (id 1002) > group (id 1989) > button "bounce" (id 1969)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

######################################################
## Constants
######################################################

constant kGravityEffect  = 1      -- how many units the ball's y vector component will gain per frame because of gravity
constant kBounceEffect   = 2      -- how many units the ball's vector will losse if if hist the edge of the card
constant kFrictionEffect = 0.01   -- how many units the ball's x vector componemnt will lose per frame because of friction

######################################################
## Variables
######################################################

local sVector               -- vector defining the ball's current motion
local sDragging             -- if we are currently dragging the ball
local sLastDragLoc          -- the last location of the ball by way of a drag
local sCurrentDragLoc       -- the next location of the ball by way of a drag

######################################################
## Properties
######################################################

## Get and set the balls vector.

## The balls vector defines the x and y components of its motion.  For example
## a vector of -5,10 means that in a frame it will move 5 pixels right and 10
## pixels down.

getProp uVector
   return sVector
end uVector

setProp uVector pX, pY
   put (pX,pY) into sVector
end uVector

local sWidth, sHeight
local sCardWidth, sCardHeight

on init
   put the width of me into sWidth
   put the height of me into sHeight
   put the width of this card into sCardWidth
   put the height of this card into sCardHeight
end init

######################################################
## Main bounce routine
######################################################

on bounceBall
   ## If the user is dragging the ball, move the ball to the location of the users
   ## mouse (or finger) and don't perform any bounce calculations.
   
   if sDragging and sCurrentDragLoc is not empty then
      set the loc of me to sCurrentDragLoc
      exit bounceBall
   end if
   
   ## Work out the balls next y location.  Add the y component of the vector to
   ## the balls y locaiton (we use the top).  If the ball is touching the top or 
   ## the bottom of the card, reverse the direction of the ball (multiply the
   ## y component of the vector by -1) and remove kBounceEffect units.
   
   ## If it is mid air, just add the effects of gravity.
   
   local tTop
   put the top of me + item 2 of sVector into tTop
   if tTop < 0 then
      put 0 into tTop
      put max(0, -1 * item 2 of sVector  - kBounceEffect) into item 2 sVector
   else if sHeight + tTop > sCardHeight then
      put sCardHeight - sHeight into tTop
      put min(0, -1 * item 2 of  sVector + kBounceEffect) into item 2 sVector
   else
      add kGravityEffect to item 2 of sVector
   end if   
   
   ## Do the same for the x location (we use the left), checking to see if the 
   ## ball is touching the sides.  This time, insetad of gravity, we take into account
   ## friction.  Unlike gravity, friciton isn't in a constant direciton.  Instead,
   ## it applies in the opposite direction the ball is travelling.
   
   local tLeft
   put the left of me + item 1 of sVector into tLeft   
   if tLeft < 0 then
      put 0 into tLeft
      put max(0, -1 * item 1 of sVector  - kBounceEffect) into item 1 sVector
   else if tLeft + sWidth > sCardWidth then
      put sCardWidth  - sWidth into tLeft
      put min(0, -1 * item 1 of sVector  + kBounceEffect) into item 1 sVector
   else
      if item 1 of sVector > 0 then
         subtract kFrictionEffect from item 1 of sVector
      else if item 1 of sVector < 0 then
         add kFrictionEffect to item 1 of sVector
      end if
   end if
   
   ## We now Know the balls new location.
   set the topLeft of me to (tLeft,tTop)
end bounceBall

######################################################
## Drag handling
######################################################

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

## Updating the balls location in the main bounce loop means that all redraws
## are carried out in the single location (within a lock screen).

on mouseMove pX, pY
   if sDragging and (pX,pY) is not sCurrentDragLoc then
      put sCurrentDragLoc into sLastDragLoc
      put (pX,pY) into sCurrentDragLoc
   end if
end mouseMove

## The user has released.  Launch the ball based on the amount the ball last moved.
## Do this by setting the x and y components of the balls vector based on how much the user
## has moved the ball in the x and y direcitons.

## Not very smart.  Should really use a time based system.
on mouseUp
   put (item 1 of sCurrentDragLoc - item 1 of sLastDragLoc, item 2 of sCurrentDragLoc - item 2 of sLastDragLoc) into sVector
   put false into sDragging
end mouseUp

on mouseRelease
   mouseUp
end mouseRelease

######################################################
## Drag handling for mobile (including multitouch)
######################################################

## Just map touch events to their mathcing mouse events.  This allows for multi-touch
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
