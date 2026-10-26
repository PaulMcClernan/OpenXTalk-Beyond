script "stack_revResourceCenter_button_id_578842"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Repeatingastringoftext" (id 109229) > group "mainContent" (id 109247) > group (id 578850) > group "Example" (id 578841) > button "Generate String" (id 578842)
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
