script "stack_revStandaloneSettings_field_id_1232"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Basic Options" (id 2037) > field "stackfiles" (id 1232)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
 updateCard
end mouseUp

on selectionChanged
  updateCard
end selectionChanged

on arrowKey
  send "updateCard" to the owner of me in 10 milliseconds
  pass arrowKey
end arrowKey

on dragEnter
  set the acceptDrop to true
end dragEnter

on dragDrop pWhat
  local tFiles
  put the dragData["files"] into tFiles
  if tFiles is not empty then
    revIncludeStackFiles tFiles
  end if
end dragDrop

getProp hilitedStackFiles
  local tStackFiles,tHilitedFiles,tItem
  local tLines
  put the hilitedLines of me into tLines
  put the cStackPaths of me into tStackFiles
  repeat for each item tItem in tLines
    put line tItem of tStackFiles & cr after tHilitedFiles
  end repeat
  delete char -1 of tHilitedFiles
  return tHilitedFiles
end hilitedStackFiles
