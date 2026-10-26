script "stack_revResourceCenter_button_id_579765"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "CompareNumbersApproximately" (id 113804) > group "mainContent" (id 113822) > group (id 113817) > group "Example" (id 579761) > button "Compare" (id 579765)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  -- check fields
  if approxEqual(field "First Number", field "Second Number", field "Tolerance") then
    answer "Yes:" && field "First Number" && "is within" && field "Tolerance" && "of" && field "Second Number" & "."
  else
    answer "No:" && field "First Number" && "is not within" && field "Tolerance" && "of" && field "Second Number" & "."
  end if
end mouseUp

function approxEqual firstNumber,secondNumber,tolerance
  if tolerance is empty then put 1 into tolerance -- default
  if abs(firstNumber - secondNumber) < tolerance
  then return true  -- the numbers are within tolerance
  else return false -- not close enough
end approxEqual
