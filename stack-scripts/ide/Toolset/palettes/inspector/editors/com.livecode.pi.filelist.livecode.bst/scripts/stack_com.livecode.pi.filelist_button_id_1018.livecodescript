script "stack_com.livecode.pi.filelist_button_id_1018"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.filelist.livecode
-- Object: stack "com.livecode.pi.filelist" > card (id 1002) > group "template" (id 1019) > button "remove" (id 1018)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   removeLines the hilitedLines of field "files"
end mouseUp
