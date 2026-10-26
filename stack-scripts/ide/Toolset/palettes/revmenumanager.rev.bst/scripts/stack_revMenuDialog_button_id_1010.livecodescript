script "stack_revMenuDialog_button_id_1010"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > substack "revMenuDialog" > card (id 1002) > button "Open Stacks" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  global gREVShowStacks
  lock messages
  set the wholeMatches to true
  put the label of me into tLabel
  put the openStacks into tOpenStacks
  if not gREVShowStacks then put revFilterStacksList(tOpenStacks) into tOpenStacks
  put tOpenStacks into me
  if tOpenStacks is empty then
    set the label of me to space
    revAnswerNoStacks
  else if tLabel is among the lines of the text of me
  then set the menuHistory of me to lineOffset(tLabel,tOpenStacks)
  unlock messages
end mouseDown

on menuPick pWhich
  lock screen
  set the cREVSelectedStack of this stack to pWhich
  set the cREVMenuIDs of this stack to empty
  revRefreshMenuField
  unlock screen
end menuPick
