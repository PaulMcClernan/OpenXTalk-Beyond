script "stack_revDocsDatabase_Types_Reference"
-- Stack file: ide/Documentation/rev/Database Types Reference.rev
-- Object: stack "revDocsDatabase Types Reference"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- --------------------------------------------------
-- revDocsDatabase Types Reference
--
-- Version:         2.0
-- Author:          Jeanne A. E. DeVoto
-- Last changed:    July 31 2003
-- Database types reference for Revolution 2.0
-- -------------------------------------------------



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
    repeat with thisField = 1 to the number of fields of group thisGroup of group "Main"
      set the height of field thisField of group thisGroup of group "Main" \
          to the formattedHeight of field thisField of group thisGroup of group "Main"
    end repeat
    get the top of field 1 of group thisGroup of group "Main"
    repeat with thisField = 2 to the number of fields of group thisGroup of group "Main"
      set the top of field thisField of group thisGroup of group "Main" to it
    end repeat
    if there is a graphic "Divider" of group thisGroup of group "Main" then \
        set the top of graphic "Divider" of group thisGroup of group "Main" \
        to the top of field 1 of group thisGroup of group "Main" - 4
    set the height of group thisGroup of group "Main" \
        to the formattedHeight of group thisGroup of group "Main"
  end repeat
  -- configure top notes group
  repeat with thisField = 1 to the number of fields of group "Labels"
    set the height of field thisField of group "Labels" to \
        the formattedHeight of field thisField of group "Labels"
  end repeat
  get the bottom of field 2 of group "Labels"
  repeat with thisField = 3 to the number of fields of group "Labels"
    set the bottom of field thisField of group "Labels" to it
  end repeat
  --set the bottom of field "Notes" of group "Labels" to \
      --  min(the top of field "Extension" of group "Labels", the top of field "Export" of group "Labels",\
      --the top of field "Mask" of group "Labels", the top of field "Comments" of group "Labels")
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
