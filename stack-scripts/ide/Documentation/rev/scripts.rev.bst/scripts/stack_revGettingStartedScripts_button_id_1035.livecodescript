script "stack_revGettingStartedScripts_button_id_1035"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Compare numbers approximately Example" (id 1031) > button "Compare" (id 1035)
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
