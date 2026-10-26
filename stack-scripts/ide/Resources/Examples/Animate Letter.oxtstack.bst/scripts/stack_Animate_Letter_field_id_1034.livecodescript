script "stack_Animate_Letter_field_id_1034"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1033) > field "Letter" (id 1034)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--a field cannot spin, so make an image from the field and spin the image

on mouseUp  --spin image
   local tName
   put the short name of me into tName
   if there is an image tName then
      answer "Sorry, there is already an image of me." with "OK" titled "Animate A Letter"
      exit to top  --stop executing code
   end if
   lock screen
   import snapshot from field tName  --make image from field
   set the name of last image to tName
   set the loc of image tName to item 1 of the loc of me &","& item 2 of the loc of me + 80  --x,y position below
   unlock screen  --show image at new loc
   set the resizeQuality of image tName to "Good"  --image quality good for spin
   --code for image ("\" continues command over > 1 line)
   set the script of image tName to  \
         "on mouseUp" &cr& \
         "repeat 3" &cr& \
         "set the angle of me to 45"  &cr& \
         "wait .5 sec with messages"  &cr& \
         "set the angle of me to -45"  &cr& \
         "wait .5 sec with messages"  &cr& \
         "end repeat"  &cr& \
         "set the angle of me to 0  --straighten"  &cr& \
         "end mouseUp"
end mouseUp
