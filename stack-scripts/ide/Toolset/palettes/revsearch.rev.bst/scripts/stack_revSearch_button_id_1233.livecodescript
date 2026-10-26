script "stack_revSearch_button_id_1233"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group "Options" (id 1371) > button "Search Marked Cards Only" (id 1233)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilite of me then enable btn "Marked or Unmarked" of stack "revSearch"
  else disable btn "Marked or Unmarked" of stack "revSearch"
end mouseUp
