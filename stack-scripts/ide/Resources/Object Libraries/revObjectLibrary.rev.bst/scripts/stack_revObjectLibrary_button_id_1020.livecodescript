script "stack_revObjectLibrary_button_id_1020"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "MacOS Standard Disclosure Triangle" (id 1019) > button "Mac Disclosure Triangle" (id 1020)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lIcon, lHiliteIcon, lResult

on mouseDown
  put the icon of me into lIcon
  if the cDisclosed of me is false then
    set the icon of me to the cHilitedIcon of me
    put the icon of me into lHiliteIcon
    withinCheck
  else
    set the icon of me to the cDisclosedHilitedIcon of me
    put the icon of me into lHiliteIcon
    withinCheck
  end if
end mouseDown

on mouseUp
  cancel lResult
  if the cDisclosed of me is false then
    set the icon of me to the cIntermediateIcon of me
    wait 10 milliseconds
    set the icon of me to the cDisclosedIcon of me
    set the cDisclosed of me to true
    set the rect of this stack to item 1 to 3 of the rect of this stack, item 2 of the rect of this stack + the cDisclosedStackHeight of me
  else
    set the icon of me to the cIntermediateIcon of me
    wait 10 milliseconds
    set the icon of me to the cIcon of me
    set the cDisclosed of me to false
    set the rect of this stack to item 1 to 3 of the rect of this stack, item 2 of the rect of this stack + the cUndisclosedStackHeight of me
  end if
end mouseUp

on mouseDoubleUp
  mouseUp
end mouseDoubleUp

on mouseRelease
  cancel lResult
  if the cDisclosed of me is false then set the icon of me to the cIcon of me
  else set the icon of me to the cDisclosedIcon of me
end mouseRelease

on withinCheck
  if within(me,the mouseLoc) then
    set the icon of me to lHiliteIcon
    send "withinCheck" to me in 20 milliseconds
    put the result into lResult
  else
    set the icon of me to lIcon
    send "withinCheck" to me in 20 milliseconds
    put the result into lResult
  end if
end withinCheck
