script "stack_Mobile_Orientation_Example_card_id_1002"
-- Stack file: ide/Resources/Mobile Examples/Orientation Example.livecode
-- Object: stack "Mobile Orientation Example" > card "Main" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openCard
   if the environment is not "mobile" then
      exit openCard
   end if
   
   updateOrientation
   
   repeat with i = 1 to the number of buttons of group "Allowed Orientations"
      set the hilite of button i of group "Allowed Orientations" to \
             (the short name of button i of group "Allowed Orientations" is among the items of iphoneAllowedOrientations())
   end repeat
end openCard

on orientationChanged
   send "updateOrientation" to me in 0 millisecs
end orientationChanged

on updateOrientation
   local tInfo
   put "Device orientation is" && iphoneDeviceOrientation() & return after tInfo
   put "Interface orientation is" && iphoneOrientation() & return after tInfo
   put "Allowed orientations are" && iphoneAllowedOrientations() & return after tInfo
   put "Orientation locked is" && iphoneOrientationLocked() & return after tInfo
   put tInfo into field "Status"
end updateOrientation

on errorDialog
   write the params to stderr
end errorDialog
