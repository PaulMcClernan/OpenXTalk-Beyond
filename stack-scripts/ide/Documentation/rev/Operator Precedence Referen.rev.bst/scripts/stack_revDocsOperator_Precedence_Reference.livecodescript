script "stack_revDocsOperator_Precedence_Reference"
-- Stack file: ide/Documentation/rev/Operator Precedence Referen.rev
-- Object: stack "revDocsOperator Precedence Reference"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on arrowKey theKey
  switch theKey
  case "down"
    put (the scroll of group "Operator Precedence" \
        + the height of group "Operator Precedence") - 20 into newScroll
    put max(zero,the formattedHeight of group "Operator Precedence" - the height of group "Operator Precedence") into maxScroll
    set the scroll of group "Operator Precedence" to min(newScroll,maxScroll)
    break
  case "up"
    put (the scroll of group "Operator Precedence" \
        - the height of group "Operator Precedence") - 20 into newScroll
    set the scroll of group "Operator Precedence" to max(newScroll,zero)
    break
  end switch
end arrowKey

on preOpenStack
  -- geometry management
  repeat with thisGroup = 2 to the number of groups
    get max(the formattedHeight of field "Category" of group thisGroup,\
        the formattedHeight of field "Operators" of group thisGroup,\
        the formattedHeight of field "Comments" of group thisGroup)
    set the height of field "Category" of group thisGroup to it
    set the height of field "Operators" of group thisGroup to it
    set the height of field "Comments" of group thisGroup to it
    if thisGroup is not 2 then set the top of graphic "Divider" of group thisGroup \
        to the top of field "Comments" of group thisGroup - 4
    set the height of group thisGroup to the formattedHeight of group thisGroup
  end repeat
  set the top of group 2 to the top of group "Operator Precedence" + 10
  repeat with x = 3 to the number of groups
    set the top of group x  to the bottom of group (x - 1)
  end repeat
  set the height of group "Operator Precedence" to the height of this stack - 13
  set the top of group "Operator Precedence" to -1
  set the scroll of group "Operator Precedence" to zero
  --pass preOpenStack
end preOpenStack

on resizeStack
  -- minWidth=maxWidth, so we only have to worry about vertical position
  set the height of group "Operator Precedence" to the height of this stack - 13
  set the top of group "Operator Precedence" to -1
  pass resizeStack
end resizeStack
