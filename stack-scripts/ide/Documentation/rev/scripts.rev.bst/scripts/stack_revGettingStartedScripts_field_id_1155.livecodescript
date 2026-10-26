script "stack_revGettingStartedScripts_field_id_1155"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Fitting a printout to the page Example" (id 1152) > field "Margin" (id 1155)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local savedNumber

on openField
  put me into savedNumber
end openField

on closeField
  if me is not a number and me is not empty then
    put savedNumber into me
    beep
    answer "This field must be a number."
    select text of me
  end if
end closeField
