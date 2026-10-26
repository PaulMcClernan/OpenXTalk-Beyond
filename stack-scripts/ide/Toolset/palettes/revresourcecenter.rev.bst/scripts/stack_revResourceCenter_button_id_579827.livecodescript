script "stack_revResourceCenter_button_id_579827"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "FindingCommonLinesInTwoContainers" (id 113650) > group "mainContent" (id 113665) > group (id 579835) > group "Example" (id 577027) > button "Common Lines" (id 579827)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  get commonLines(field "List 1", field "List 2")
  if it is empty then answer "There are no lines in common."
  else answer it
end mouseUp
  
function commonLines firstList,secondList
  repeat for each line thisLine in firstList
    put true into firstArray[thisLine]
  end repeat
  repeat for each line thisLine in secondList
    put true into secondArray[thisLine]
  end repeat
  intersect firstArray with secondArray
  return the keys of firstArray
end commonLines
