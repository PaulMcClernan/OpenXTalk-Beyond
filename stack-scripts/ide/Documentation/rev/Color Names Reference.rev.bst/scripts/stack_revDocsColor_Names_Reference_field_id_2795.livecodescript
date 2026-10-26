script "stack_revDocsColor_Names_Reference_field_id_2795"
-- Stack file: ide/Documentation/rev/Color Names Reference.rev
-- Object: stack "revDocsColor Names Reference" > card "Color Chart" (id 1002) > field "Color Name" (id 2795)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  put quote & text of the target & quote into field "Copy Container"
  select text of field "Copy Container"
  copy
end mouseDown
