script "stack_revSearch_scrollbar_id_1383"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > scrollbar "Results" (id 1383)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag x
  if "hSelectionUpdate" is in the pendingMessages then
    cancel (item 1 of line lineOffset("hSelectionUpdate",the pendingMessages) of the pendingMessages)
  end if
  lock messages
  set the scroll of fld "stack" to x
  set the scroll of fld "type" to x
  set the scroll of fld "card" to x
  set the scroll of fld "name" to x
  unlock messages
end scrollbarDrag
