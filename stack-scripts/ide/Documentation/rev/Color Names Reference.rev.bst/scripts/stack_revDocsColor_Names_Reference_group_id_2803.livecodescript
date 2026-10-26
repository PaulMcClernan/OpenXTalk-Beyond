script "stack_revDocsColor_Names_Reference_group_id_2803"
-- Stack file: ide/Documentation/rev/Color Names Reference.rev
-- Object: stack "revDocsColor Names Reference" > card "Color Chart" (id 1002) > group "Swatches" (id 2803)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  if the owner of the target is not me then pass mouseDown
  put the short name of the target into field "Color Name"
  put "RGB:" && the numericColor of the target into field "RGB"
  put "HTML:" && the htmlColor of the target into field "HTML"
  set the backgroundColor of graphic "Large Swatch" to the short name of the target
end mouseDown
