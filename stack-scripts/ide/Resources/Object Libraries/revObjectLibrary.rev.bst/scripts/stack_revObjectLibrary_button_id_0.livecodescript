script "stack_revObjectLibrary_button_id_0"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "Object Move Widget Horizontal" (id 1095) > group "Object Move Widget Horizontal" (id 1096) > button "Object Move Widget Horizontal" (id 0)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lIcon, lResult

on mouseDown
  if the icon of me is (the cMoveRightIcon of me) then
    put the icon of me into lIcon
    set the icon of me to the cMoveRightHiliteIcon of me
    hWithinCheck
  else if the icon of me is (the cMoveLeftIcon of me) then
    put the icon of me into lIcon
    set the icon of me to the cMoveLeftHiliteIcon of me
    hWithinCheck
  end if
end mouseDown

on mouseUp
  cancel lResult
  if lIcon is the cMoveRightIcon of me then
    set the icon of me to the cMoveLeftIcon of me
    
    --MOVE OR SET LOC OR PROPERTIES OF RELEVANT OBJECTS
    move fld "My Field 3" relative 100,0 in 200 millisecs without waiting
    move fld "My Field 4" relative 0,+50 in 200 millisecs
    
  else
    set the icon of me to the cMoveRightIcon of me
     
    --MOVE OR SET LOC OR PROPERTIES OF RELEVANT OBJECTS
    move fld "My Field 4" relative 0,-50 in 200 millisecs without waiting
    move fld "My Field 3" relative -100,0 in 200 millisecs
     
  end if
end mouseUp

on mouseRelease
  cancel lResult
  set the icon of me to lIcon
end mouseRelease

on hWithinCheck
  if within(me, the mouseLoc) then
    if lIcon is the cMoveRightIcon of me then
      set the icon of me to the cMoveRightHiliteIcon of me
    else if lIcon is the cMoveLeftIcon of me then
      set the icon of me to the cMoveLeftHiliteIcon of me
    end if
    if "hWithinCheck" is not in the pendingMessages then send "hWithinCheck" to me in 20 milliseconds
    put the result into lResult
  else
    set the icon of me to lIcon
    if "hWithinCheck" is not in the pendingMessages then send "hWithinCheck" to me in 20 milliseconds
    put the result into lResult
  end if
end hWithinCheck
