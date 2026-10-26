script "stack_Report_Builder_scrollbar_id_1021"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > group "Tab Stops" (id 1022) > scrollbar "Scrollbar" (id 1021)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --tabstops for columns
   set the tabStops of fld "Text" of stack "Report" to the thumbPosition of me
end mouseUp
