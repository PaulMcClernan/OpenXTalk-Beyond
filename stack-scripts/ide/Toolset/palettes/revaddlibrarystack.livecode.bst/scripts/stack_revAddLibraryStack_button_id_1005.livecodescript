script "stack_revAddLibraryStack_button_id_1005"
-- Stack file: ide/Toolset/palettes/revaddlibrarystack.livecode
-- Object: stack "revAddLibraryStack" > card (id 1002) > button "Stack" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  lock screen
  put the label of me into tLabel
  put revLoadedStacks("preference") into tStacks
  put tStacks into me
  
  set the wholeMatches to true
  if tLabel is among the lines of tStacks 
  then set the menuHistory of me to lineOffset(tLabel,tText)
  unlock screen
end mouseDown

on menuPick pWhich
  if there is a stack pWhich then enable btn "OK"
  else disable btn "OK"
  pass menuPick
end menuPick
