script "stack_revObjectProperties_group_id_1031"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > substack "revObjectProperties" > card (id 1002) > group "Other Properties" (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilite of btn "specific property" is true then enable btn "specific property selector"
  else disable btn "specific property selector"
end mouseUp
