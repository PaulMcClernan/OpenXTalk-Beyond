script "stack_Animate_a_Letter_field_id_1193"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Keep Score" (id 1037) > field "Letter" (id 1193)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown  --grab with mouse
   grab me  --move me around with mouse
end mouseDown

on mouseMove x,y  --better than mouseStillDown
   if intersect(me,graphic "Ball") then
      hide me  --release mouseDown grab
      set the loc of me to the cStartLoc of me  --start over, cStartLoc is a custom property of field "Letter"
      show me
      set the loc of graphic "Ball" to random(240)+300, random(400)+170  --random x,y on the stage
      beep
      add 10 to field "Score"  --win
      get the text of field "Score"  --put in temp container "it"
      if it = "10" then answer "You caught the Red Ball and scored 10 points! Yaaaa!" with "OK" titled "You Won"  --optional
      else if it >= "20" and it <= "50" then revSpeak "You have" && it && "points."  --optional
   end if
end mouseMove

on mouseUp
   move me from the loc of me to the cStartLoc of me  --back to starting point
end mouseUp
