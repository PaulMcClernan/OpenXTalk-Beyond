script "stack_Balls_card_id_1002"
-- Stack file: ide/Resources/Start Center/samples/sample_1/Balls.livecode
-- Object: stack "Balls" > card "main" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

######################################################
## Constants
######################################################

## How often in milliseconds the location of the balls are updated
constant kBouncePollRate = 25   

######################################################
## Variables
######################################################
## List of the balls (comma separated list of control ids)
local sObjects              

## How many balls will be created in the next loop
local sCreateCount        

## Whether existing balls should be cleared in the next loop  
local sClearBalls                

######################################################
## Main loop
######################################################
/* All the calculations, creating and moving of the balls takes place in this loop.  Using a single loop
like this means we can manage all redraws within a single screem update rather than a screen update for
each ball that moves and each ball we want to create.

Note the use of lock screen.  Though we are potentially moving and creating several balls within this loop,
since it is all performed while the screen is locked, only one redraw will be made.

Our loop will be called every kBouncePollRate milliseconds.  We make sure this is consistent by taking into
account the time the loop takes to execute.  Say for example we want to redraw every 25 milliseconds
and the loop itself takes 5 milliseconds, we must then perform the next redraw in 20 milliseconds.  This
is worked out dynamically by calculating the time each loop takes to execute and adjusting the send time accprdingly.

If the loop takes greater than the poll rate to run, we call the next loop instantly, telling it how much longer 
it took.  This overun time is taken into account when sending the next loop.  For example, if the previous
loop overran by 5 milliseconds, we must dispatch the next loop 5 milliseconds early than we would normally do.

If the overrun is greater than the poll rate, then we must perform multiple repetitions.  For example, if the previous
loop overran by 30 milliseconds, we know that we have missed out a redraw entirely.   To accomodate this, we must peform
 two repetitions of the main loop.  That is, we move the balls two frames, but only redraw once, effectively dropping
 a frame.  This keeps the speed of the balls consistent, even if the hardware can't keep up. */
 
 on openCard
    ## Cause the main loop to be started when the card is opened
    clearBalls
    send "bounceBalls 0" to me in 0 seconds
    
    ## For demonstration create and agitate balls
    send "newBalls 20" to me in 0 seconds
    send "shakeBalls" to me in 200 milliseconds
end openCard

on bounceBalls pTimeMissed
   ## Log the start time of this loop (so we can calculate how long it takes).
   ## If the previous loop overran by more than the poll rate, we need to perform
   ## extra reps in this loop.  Calculate how many (how many frames have been missed).
   
   local tStartTime, tReps
   put the milliseconds into tStartTime
   if pTimeMissed > kBouncePollRate then
      put pTimeMissed div kBouncePollRate into tReps
      subtract tReps * kBouncePollRate from pTimeMissed
   else
      put 1 into tReps
   end if
   
   ## Create any new balls required and then move all the active balls.  If we missed frames
   ## then make sure we move the balls the required number of extra times to accomodate
   ## the missed frames.
   lock screen
   if sClearBalls then
      repeat for each item tObject in sObjects
         delete tObject
      end repeat 
      put empty into sObjects
      put false into sClearBalls   
   else
      repeat while sCreateCount > 0
         createBall
         subtract 1 from sCreateCount
      end repeat
      repeat tReps times
         repeat for each item tObject in sObjects
            send "bounceBall" to tObject
         end repeat
      end repeat
   end if
   unlock screen
   
   ## Work out how long this loop took and based on this value, call the next loop.
   ## If this loop overran, make sure to tell the next loop.
   
   get kBouncePollRate - (the milliseconds - tStartTime) - pTimeMissed
   send "bounceBalls" && max(0, it * -1) to me in max(0, it) milliseconds
end bounceBalls

######################################################
## Ball create/edit/delete handlers
######################################################
/*Create a new circle of a random size and set its behavior.  The code in button
bounce defines the behavior of the ball, from how it interacts with the user (dragging) to 
how it is to bounce around the screen.

The important point to note here is the setting of the layerMode of the new graphic to "dynamic".
This tells the compositor that the location of this control will be changing regularly and to
adjust its caching routines accordingly.*/

on createBall
   local tSize
   put max(10, random(100)) into tSize
   
   create graphic
   set the behavior of it to the long id of button "bounce"
   set the layerMode of it to "dynamic"
   set the loc of it to the mouseloc
   set the width of it to tSize
   set the height of it to tSize
   set the style of it to "oval"
   set the opaque of it to true
   set the linesize of it to 2
   set the backgroundColor of it to any word of the colorNames
   send "init" to it
   if sObjects is not empty then 
      put comma after sObjects
   end if
   put it after sObjects   
end createBall

## Simulate a shake.  Here, we just tell the balls to move in a random direction.
## The actual movement of the balls will be taken care of in the main loop.

on shakeBalls
   repeat for each item tObject in sObjects
      set the uVector of tObject to (35 - random(70), 35 - random(70))
   end repeat   
end shakeBalls

## Remaove all the balls.  Like creating a new balls, we just set a flag so that
## the clear happens in the next main loop.

on clearBalls
   put true into sClearBalls
end clearBalls

on newBalls pCount
   add pCount to sCreateCount
end newBalls

######################################################
## User interaction handlers
######################################################

## When the user clicks (or touches), create a new ball.  Rather than create the ball directly here, we increment
## the count and create the ball in the main loop. 

on mouseDown
   add 1 to sCreateCount
end mouseDown

on motionStart
   shakeBalls
end motionStart
