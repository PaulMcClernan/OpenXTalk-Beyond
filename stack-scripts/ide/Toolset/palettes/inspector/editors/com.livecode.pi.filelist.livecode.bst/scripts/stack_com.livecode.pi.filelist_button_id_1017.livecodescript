script "stack_com.livecode.pi.filelist_button_id_1017"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.filelist.livecode
-- Object: stack "com.livecode.pi.filelist" > card (id 1002) > group "template" (id 1019) > button "add folder" (id 1017)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   answer folder "Select a folder to add:"
   if it is empty then exit mouseUp
   dispatch "addEntry" with it
end mouseUp
