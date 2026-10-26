script "stack_revDocsMemory_and_Limits_Reference"
-- Stack file: ide/Documentation/rev/Memory and Limits Reference.rev
-- Object: stack "revDocsMemory and Limits Reference"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on arrowKey theKey
  switch theKey
  case "down"
    put (the scroll of group "Limits" \
        + the height of group "Limits") - 20 into newScroll
    put max(zero,the formattedHeight of group "Limits" - the height of group "Limits") into maxScroll
    set the scroll of group "Limits" to min(newScroll,maxScroll)
    break
  case "up"
    put (the scroll of group "Limits" \
        - the height of group "Limits") - 20 into newScroll
    set the scroll of group "Limits" to max(newScroll,zero)
    break
  end switch
end arrowKey

on preOpenStack
  -- geometry management
  repeat with thisGroup = 3 to the number of groups
    get max(the formattedHeight of field "Description" of group thisGroup,\
        the formattedHeight of field "Limit" of group thisGroup)
    set the height of field "Description" of group thisGroup to it
    set the height of field "Limit" of group thisGroup to it
    if there is a graphic "Divider" of group thisGroup then set \
        the top of graphic "Divider" of group thisGroup \
        to the top of field "Description" of group thisGroup - 4
    set the height of group thisGroup to the formattedHeight of group thisGroup
  end repeat
  set the height of field "Comments" of group "Top Comments" to \
      the formattedHeight of field "Comments" of group "Top Comments"
  set the height of group "Top Comments" to the formattedHeight of group "Top Comments"
  set the top of group "Top Comments" to the top of group "Limits" + 10
  repeat with x = 3 to the number of groups
    set the top of group x  to the bottom of group (x - 1)
  end repeat
  set the height of group "Limits" to the height of this stack - 13
  set the top of group "Limits" to -1
  set the scroll of group "Limits" to zero
  pass preOpenStack
end preOpenStack

on resizeStack
  -- minWidth=maxWidth, so we only have to worry about vertical position
  set the height of group "Limits" to the height of this stack - 13
  set the top of group "Limits" to -1
  pass resizeStack
end resizeStack
