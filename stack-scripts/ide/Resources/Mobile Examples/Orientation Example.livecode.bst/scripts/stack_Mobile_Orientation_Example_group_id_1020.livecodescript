script "stack_Mobile_Orientation_Example_group_id_1020"
-- Stack file: ide/Resources/Mobile Examples/Orientation Example.livecode
-- Object: stack "Mobile Orientation Example" > card "Main" (id 1002) > group "Allowed Orientations" (id 1020)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   get empty
   repeat with i = 1 to the number of buttons of me
      if the hilite of button i of me then
         put the short name of button i of me & comma after it
      end if
   end repeat
   delete the last char of it
   if it is empty then
      get "portrait"
   end if
   iphoneSetAllowedOrientations it
   updateOrientation
end mouseUp
