script "stack_revGettingStartedScripts_field_id_1034"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Compare numbers approximately Example" (id 1031) > field "Second Number" (id 1034)
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
