script "stack_revSearch_button_id_1318"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group "Properties" (id 1359) > button "Field Text" (id 1318)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cFieldText of stack "revSearch" to the hilite of me
end mouseUp
