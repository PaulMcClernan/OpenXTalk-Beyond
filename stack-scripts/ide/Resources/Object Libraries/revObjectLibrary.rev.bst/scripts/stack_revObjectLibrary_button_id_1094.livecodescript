script "stack_revObjectLibrary_button_id_1094"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "Little Arrows MacOS Standard" (id 1093) > button "Little Arrows" (id 1094)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lTrackingIcon, lTracking, lCancelID

on mouseUp
  cancel lCancelID
  put false into lTracking
  set the icon of me to the cIcon of me
end mouseUp

on mouseDoubleUp
  mouseUp
end mouseDoubleUp

on mouseDoubleDown
  mouseDown
end mouseDoubleDown

on mouseMove x,y
  if lTracking then
    put x,y into tLoc
    if within (me,tLoc) then
      if the icon of me is not lTrackingIcon then
        set the icon of me to lTrackingIcon
        if lTrackingIcon is the cUpIcon of me then hAddToField
        else if lTrackingIcon is the cDownIcon of me then hSubtractFromField
      end if
    else
      set the icon of me to the cIcon of me
    end if
  end if
end mouseMove

on mousedown 
  if the mouseV < (the top of me + 11) then put the cUpIcon of me into lTrackingIcon
  else put the cDownIcon of me into lTrackingIcon
  set the icon of me to lTrackingIcon
  if lTrackingIcon is the cUpIcon of me then hAddToField
  else if lTrackingIcon is the cDownIcon of me then hSubtractFromField
  put true into lTracking
  if "hTimeMove" is not in the pendingMessages then send "hTimeMove" to me in 250 milliseconds
  put the result into lCancelID
end mousedown

on hTimeMove
  if not lTracking then exit hTimeMove
  if the icon of me is the cUpIcon of me then hAddToField
  else if the icon of me is the cDownIcon of me then hSubtractFromField
  if "hTimeMove" is not in the pendingMessages then send "hTimeMove" to me in 50 milliseconds
  put the result into lCancelID
end hTimeMove

on mouseRelease
  mouseUp
end mouseRelease

on hAddToField
  if the text of the fld (the cTargetField of me) < the cMaxValue of fld (the cTargetField of me) then add 1 to fld (the cTargetField of me)
  send "closeField" to fld (the cTargetField of me)
end hAddToField

on hSubtractFromField
  if the text of the fld (the cTargetField of me) > the cMinValue of fld (the cTargetField of me) then subtract 1 from fld (the cTargetField of me)
  send "closeField" to fld (the cTargetField of me)
end hSubtractFromField
