script "stack_com.livecode.pi.datagrid_group_id_1053"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.datagrid.livecode
-- Object: stack "com.livecode.pi.datagrid" > card (id 1002) > group "template" (id 1012) > group "row template" (id 1053)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on subEditorResize
   lock screen
   lock messages
   
   set the width of button 1 of me to the width of me
   set the left of button 1 of me to the left of me
   set the top of button 1 of me to the top of me
   
   unlock messages
   unlock screen
end subEditorResize
