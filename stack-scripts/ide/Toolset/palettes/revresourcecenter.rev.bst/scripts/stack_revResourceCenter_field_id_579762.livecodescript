script "stack_revResourceCenter_field_id_579762"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "CompareNumbersApproximately" (id 113804) > group "mainContent" (id 113822) > group (id 113817) > group "Example" (id 579761) > field "First Number" (id 579762)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local savedNumber

on openField
  put me into savedNumber
end openField

on closeField
  if me is not a number or me is empty then
    put savedNumber into me
    beep
    answer "This field must be a number."
    select text of me
  end if
end closeField
