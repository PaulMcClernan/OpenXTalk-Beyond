script "stack_revObjectLibrary_field_id_1058"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "Auto Scrolling Field" (id 1057) > field "Auto Scrolling Field" (id 1058)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lScroll, lCount

on mouseUp
  put empty into lCount
  put the formattedHeight of me - the height of me into lScroll
  hScrollDown
end mouseUp

on hScrollDown
  if lCount < lScroll then
    add 1 to lCount
    set the scroll of me to lCount
    send "hScrollDown" to me in (the cScrollInterval of me) millisecs
  else
    hScrollBack
  end if
end hScrollDown

on hScrollBack
  set the scroll of me to 0
end hScrollBack
