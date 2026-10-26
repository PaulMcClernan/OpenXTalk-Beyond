script "stack_revResourceCenter_button_id_579833"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "FindingLinesThatAreNotCommonToTwoContainers" (id 113667) > group "mainContent" (id 113683) > group (id 579836) > group "Example" (id 577028) > button "Uncommon Lines" (id 579833)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  get uncommonLines(field "List 1", field "List 2")
  if it is empty then answer "There are no differing lines."
  else answer it
end mouseUp
 
function uncommonLines firstList,secondList
  -- find lines in the first list but not the second list:
  repeat for each line thisLine in firstList
    if thisLine is not in secondList then -- include this line
      put "-" && thisLine & return after uncommon
    end if
  end repeat
  -- find lines in the second list but not the first list:
  repeat for each line thatLine in secondList
    if thatLine is not in firstList then -- include this line
      put "+" && thatLine & return after uncommon
    end if
  end repeat
  if last char of uncommon is return
  then delete last char of uncommon -- strip trailing return
  return uncommon
end uncommonLines
