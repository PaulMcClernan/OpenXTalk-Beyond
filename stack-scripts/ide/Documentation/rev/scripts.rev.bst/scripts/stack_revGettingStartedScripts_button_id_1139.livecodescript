script "stack_revGettingStartedScripts_button_id_1139"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Finding common lines in two containers Example" (id 1134) > button "Common Lines" (id 1139)
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
