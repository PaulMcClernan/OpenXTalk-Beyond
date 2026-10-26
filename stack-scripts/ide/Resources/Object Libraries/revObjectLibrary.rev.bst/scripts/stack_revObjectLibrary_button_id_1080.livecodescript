script "stack_revObjectLibrary_button_id_1080"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "Windows Standard Hierarchical Field Widget" (id 1079) > button "Windows Hierarchical Field Widget" (id 1080)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lResult, lHilite

on mouseDown
  put the hilite of me into lHilite
  set the hilite of me to not the hilite of me
  hWithinCheck
end mouseDown

on mouseDoubleDown
  mouseDown
end mouseDoubleDown

on mouseUp
  cancel lResult
  set the hilite of me to not lHilite
end mouseUp

on mouseRelease
  cancel lResult
  if within(me,the mouseLoc) then set the hilite of me to not lHilite
  else set the hilite of me to lHilite
end mouseRelease

on hWithinCheck
  if within(me,the mouseLoc) then
    set the hilite of me to not lHilite
    if "hWithinCheck" is not in the pendingMessages then send "hWithinCheck" to me in 20 milliseconds
    put the result into lResult
  else
    set the hilite of me to lHilite
    if "hWithinCheck" is not in the pendingMessages then send "hWithinCheck" to me in 20 milliseconds
    put the result into lResult
  end if
end hWithinCheck
