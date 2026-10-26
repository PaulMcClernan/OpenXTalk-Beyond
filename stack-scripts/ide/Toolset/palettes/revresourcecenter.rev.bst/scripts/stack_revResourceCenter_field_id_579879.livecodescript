script "stack_revResourceCenter_field_id_579879"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "FittingaPrintouttothePage" (id 77973) > group "mainContent" (id 77984) > group (id 579880) > group "Example" (id 577042) > field "Margin" (id 579879)
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
