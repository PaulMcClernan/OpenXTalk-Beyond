script "stack_revSearch_button_id_1296"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group "Specific Stack" (id 1364) > button (id 1296)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  global gREVShowStacks
  set the wholeMatches to true
  put the openStacks into tOpenStacks
  if not gREVShowStacks then put revFilterStacksList(tOpenStacks) into tOpenStacks
  set the text of me to tOpenStacks
  hilite me
end mouseDown

on menuPick pWhich
  set the text of fld "specific stack" of stack "revSearch" to pWhich
  unhilite me
end menuPick

on mouseUp
  unhilite me
  pass mouseUp
end mouseUp

on mouseRelease
  unhilite me
  pass mouseRelease
end mouseRelease
