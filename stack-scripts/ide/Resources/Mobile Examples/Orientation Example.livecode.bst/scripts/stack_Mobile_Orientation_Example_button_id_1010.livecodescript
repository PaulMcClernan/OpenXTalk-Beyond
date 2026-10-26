script "stack_Mobile_Orientation_Example_button_id_1010"
-- Stack file: ide/Resources/Mobile Examples/Orientation Example.livecode
-- Object: stack "Mobile Orientation Example" > card "Main" (id 1002) > button "Lock Orientation" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me then
      iphoneLockOrientation
   else
      iphoneUnlockOrientation
   end if
   updateOrientation
end mouseUp
