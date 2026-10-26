script "stack_Animate_Letter_card_id_1088"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1088)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on arrowKey pKey  --in cd script, move field "Letter" and graphic "Ball"
   lock screen
   if pKey = "up" then
      if the top of fld "Letter" > the top of graphic "Boundry" then  --hidden graphic
         set the top of fld "Letter" to the top of fld "Letter" -10  --move up
      end if
   else if pKey = "down" then
      if the bottom of fld "Letter" < the bottom of graphic "Boundry" then
         set the bottom of fld "Letter" to the bottom of fld "Letter" +10  --move down
      end if
   else if pKey = "left" then
      if the left of fld "Letter" > the left of graphic "Boundry" then
         set the left of fld "Letter" to the left of fld "Letter" -10  --move left
      end if
   else if pKey = "right" then
      if the right of fld "Letter" < the right of graphic "Boundry" then
         set the right of fld "Letter" to the right of fld "Letter" +10  --move right
      end if
   end if
   if random(10) = "10" then  --random reposition graphic "Ball"
      set the loc of grc "Ball" to (the left of graphic "Boundry" + random(the right of graphic "Boundry" -150)+75 &","& \
            the top of graphic "Boundry" + random(the bottom of graphic "Boundry" -150)+75)
      repeat while intersect(fld "Letter",grc "Ball")  --try again
         set the loc of grc "Ball" to (the left of graphic "Boundry" + random(the right of graphic "Boundry" -150)+75 &","& \
               the top of graphic "Boundry" + random(the bottom of graphic "Boundry" -150)+75)
      end repeat
   end if
   unlock screen
   if intersect(fld "Letter",grc "Ball") then  --win
      add 10 to fld "Score"
      get fld "Score"
      revSpeak "You captured the Red Ball and now have" &&it&& "points."
      if it mod 30 = 0 then revSpeak "And moved to the next level."  --score/30 = no remainder: 30,60,90...
      send "mouseUp" to fld "Letter"  --reset
   end if
end arrowKey
