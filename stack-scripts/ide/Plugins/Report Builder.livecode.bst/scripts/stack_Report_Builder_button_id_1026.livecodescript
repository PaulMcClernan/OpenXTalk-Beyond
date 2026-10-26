script "stack_Report_Builder_button_id_1026"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > group "Options" (id 1027) > button "Header" (id 1026)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me then set the hilite of btn "Footer" of grp "Options" to "false"  --one or no selection
end mouseUp
