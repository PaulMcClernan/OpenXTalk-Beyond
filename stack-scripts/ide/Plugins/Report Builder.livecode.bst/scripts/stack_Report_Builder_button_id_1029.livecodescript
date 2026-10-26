script "stack_Report_Builder_button_id_1029"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > group "Options" (id 1027) > button "Footer" (id 1029)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me then set the hilite of btn "Header" of grp "Options" to "false"  --one or no selection
end mouseUp
