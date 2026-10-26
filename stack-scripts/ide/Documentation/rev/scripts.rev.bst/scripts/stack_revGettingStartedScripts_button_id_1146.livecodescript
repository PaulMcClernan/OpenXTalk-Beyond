script "stack_revGettingStartedScripts_button_id_1146"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Finding lines that are not common to two containers Example" (id 1141) > button "Uncommon Lines" (id 1146)
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
