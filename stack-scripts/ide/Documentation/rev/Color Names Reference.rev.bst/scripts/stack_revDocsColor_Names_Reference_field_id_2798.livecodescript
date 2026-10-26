script "stack_revDocsColor_Names_Reference_field_id_2798"
-- Stack file: ide/Documentation/rev/Color Names Reference.rev
-- Object: stack "revDocsColor Names Reference" > card "Color Chart" (id 1002) > field "HTML" (id 2798)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  get text of the target
  delete word 1 of it
  put quote & it & quote into field "Copy Container"
  select text of field "Copy Container"
  copy
end mouseDown
