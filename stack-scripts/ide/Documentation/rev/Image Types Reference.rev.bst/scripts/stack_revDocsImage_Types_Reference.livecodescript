script "stack_revDocsImage_Types_Reference"
-- Stack file: ide/Documentation/rev/Image Types Reference.rev
-- Object: stack "revDocsImage Types Reference"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on arrowKey theKey
  if the style of this stack is "toplevel" then pass arrowKey
  switch theKey
  case "down"
    put (the scroll of group "Main" \
        + the height of group "Main") - 20 into newScroll
    put max(zero,the formattedHeight of group "Main" - the height of group "Main") into maxScroll
    set the scroll of group "Main" to min(newScroll,maxScroll)
    break
  case "up"
    put (the scroll of group "Main" \
        - the height of group "Main") - 20 into newScroll
    set the scroll of group "Main" to max(newScroll,zero)
    break
  end switch
end arrowKey

on preOpenStack
  -- geometry management
  repeat with thisGroup = 1 to the number of groups of group "Main" -- only the subgroups
    set the height of field "Type" of group thisGroup of group "Main" \
        to the formattedHeight of field "Type" of group thisGroup of group "Main"
    set the height of field "Extension" of group thisGroup of group "Main" \
        to the formattedHeight of field "Extension" of group thisGroup of group "Main"
    set the height of field "Export" of group thisGroup of group "Main" \
        to the formattedHeight of field "Export" of group thisGroup of group "Main"
    set the height of field "Mask" of group thisGroup of group "Main" \
        to the formattedHeight of field "Mask" of group thisGroup of group "Main"
    set the height of field "Comments" of group thisGroup of group "Main" \
        to the formattedHeight of field "Comments" of group thisGroup of group "Main"
    --
    get the top of field "Type" of group thisGroup of group "Main"
    set the top of field "Extension" of group thisGroup of group "Main" to it
    set the top of field "Export" of group thisGroup of group "Main" to it
    set the top of field "Mask" of group thisGroup of group "Main" to it
    set the top of field "Comments" of group thisGroup of group "Main" to it
    --
    if there is a graphic "Divider" of group thisGroup of group "Main" then \
        set the top of graphic "Divider" of group thisGroup of group "Main" \
        to the top of field "Type" of group thisGroup of group "Main" - 4
    set the height of group thisGroup of group "Main" to the formattedHeight of group thisGroup of group "Main"
  end repeat
  -- configure top notes group
  set the height of field "Notes" of group "Labels" to \
      the formattedHeight of field "Notes" of group "Labels"
  set the height of field "Extension" of group "Labels" to \
      the formattedHeight of field "Extension" of group "Labels"
  set the height of field "Export" of group "Labels" to \
      the formattedHeight of field "Export" of group "Labels"
  set the height of field "Mask" of group "Labels" to \
      the formattedHeight of field "Mask" of group "Labels"
  set the bottom of field "Extension" of group "Labels" to the bottom of field "Comments" of group "Labels"
  set the bottom of field "Export" of group "Labels" to the bottom of field "Comments" of group "Labels"
  set the bottom of field "Mask" of group "Labels" to the bottom of field "Comments" of group "Labels"
  set the bottom of field "Notes" of group "Labels" to \
      min(the top of field "Extension" of group "Labels", the top of field "Export" of group "Labels",\
      the top of field "Mask" of group "Labels", the top of field "Comments" of group "Labels")
  set the height of group "Labels" to the formattedHeight of group "Labels"
  set the top of group "Labels" to -1
  --
  repeat with x = 2 to the number of groups of group "Main"
    set the top of group x of group "Main" to the bottom of group (x - 1) of group "Main"
  end repeat
  if the platform is "Win32" then
    set the height of group "Main" to the height of this stack - the height of group "Labels" + 2
  else
    set the height of group "Main" to the height of this stack - the height of group "Labels" - 13 + 2
  end if
  set the top of group "Main" to the bottom of group "Labels" - 2
  set the scroll of group "Main" to zero
  --pass preOpenStack
end preOpenStack

on resizeStack
  get the scroll of group "Main"
  set the scroll of group "Main" to zero
  if the platform is "Win32" then
    set the height of group "Main" to the height of this stack - the height of group "Labels" + 2
  else
    set the height of group "Main" to the height of this stack - the height of group "Labels" - 13 + 2
  end if
  -- minWidth=maxWidth, so we only have to worry about vertical position
  put max(zero,the formattedHeight of group "Main" - the height of group "Main" - the height of group "Labels") into maxScroll
  set the scroll of group "Main" to min(it,maxScroll)
  pass resizeStack
end resizeStack
