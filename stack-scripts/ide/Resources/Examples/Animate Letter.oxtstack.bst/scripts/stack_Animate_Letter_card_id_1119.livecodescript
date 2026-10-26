script "stack_Animate_Letter_card_id_1119"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1119)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sLose  --declare script local container, available to all scripts below it
on arrowKey pKey  --in cd script, make field "Letter" jump over graphic "Ball"
   if pKey = "up" then  --start game or jump
      if the loc of graphic "Ball" = the cStartLoc of graphic "Ball" then  --start game  (move left with -x,y in 4 to 7 seconds)
         move grc "Ball" relative -(the left of grc "Ball" - the left of graphic "Boundry"),0 in random(4)+3 secs without waiting  --don't wait while moving
      else  --jump
         if the right of grc "Ball" < the left of fld "Letter" then exit to top  --jump after ball passes
         repeat with i = 1 to 16
            if i <= "8" then set the top of field "Letter" to the top of field "Letter" -10  --jump up
            else set the top of field "Letter" to the top of field "Letter" +10  --come down
            wait 200 millisecs with messages  --adjust jump speed, with messages allows engine to process
            put intersect(field "Letter",graphic "Ball") into sLose  --sLose="true" if they touch
            if sLose = "true" then exit repeat
         end repeat
      end if
   end if
end arrowKey

on moveStopped  --moving object reaches destination
   if sLose = "true" then subtract 10 from field "Score"  --lose
   else if sLose = "false" then add 10 to field "Score"  --win
   put empty into sLose  --reset, script local containers are persistent while stack is open
   set the loc of field "Letter" to the cStartLoc of field "Letter"  --reset, cStartLoc is custom property of field "Letter"
   set the loc of graphic "Ball" to the cStartLoc of graphic "Ball"  --reset, cStartLoc is custom property of graphic "Ball"
   exit to top  --stop all running scripts
end moveStopped
