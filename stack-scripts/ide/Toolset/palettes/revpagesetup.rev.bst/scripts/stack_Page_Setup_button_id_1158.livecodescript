script "stack_Page_Setup_button_id_1158"
-- Stack file: ide/Toolset/palettes/revpagesetup.rev
-- Object: stack "Page Setup" > card "Print Setup Card" (id 1001) > group "Packing" (id 1110) > button "scrollbar widget 3" (id 1158)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

  

local lTrackingIcon, lTracking, lCancelID

on mouseUp
  cancel lCancelID
  put false into lTracking
  set the icon of me to 201317
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
        if lTrackingIcon is 201319 then revAddToField
        else if lTrackingIcon is 201318 then revSubtractFromField
      end if
    else
      set the icon of me to 201317
    end if
  end if
end mouseMove

on mousedown 
  if the mouseV < (the top of me + 10) then put 201319 into lTrackingIcon
  else put 201318 into lTrackingIcon
  set the icon of me to lTrackingIcon
  if lTrackingIcon is 201319 then revAddToField
  else if lTrackingIcon is 201318 then revSubtractFromField
  put true into lTracking
  if "revTimeMove" is not in the pendingMessages then send "revTimeMove" to me in 250 milliseconds
  put the result into lCancelID
end mousedown

on revTimeMove
  if not lTracking then exit revTimeMove
  if the icon of me is 201319 then revAddToField
  else if the icon of me is 201318 then revSubtractFromField
  if "revTimeMove" is not in the pendingMessages then send "revTimeMove" to me in 50 milliseconds
  put the result into lCancelID
end revTimeMove

on mouseRelease
  mouseUp
end mouseRelease

on revAddToField
  if the text of the fld (the cTargetField of me) < the cMaxValue of fld (the cTargetField of me) then add 1 to fld (the cTargetField of me)
  send "closeField" to fld (the cTargetField of me)
end revAddTofield

on revSubtractFromField
  if the text of the fld (the cTargetField of me) > the cMinValue of fld (the cTargetField of me) then subtract 1 from fld (the cTargetField of me)
  send "closeField" to fld (the cTargetField of me)
end revSubtractFromField
