script "stack_revGettingStartedScripts_button_id_1060"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Repeating a string of text Example" (id 1059) > button "Generate String" (id 1060)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put repeatedString(field "String",field "Number") into field "Result"
end mouseUp
 
function repeatedString theString,numberOfTimes
  if numberOfTimes is empty \
      or numberOfTimes is not an integer \
      then put 1 into numberOfTimes
  repeat for numberOfTimes
    put theString after finalString
  end repeat
  return finalString
end repeatedString 
