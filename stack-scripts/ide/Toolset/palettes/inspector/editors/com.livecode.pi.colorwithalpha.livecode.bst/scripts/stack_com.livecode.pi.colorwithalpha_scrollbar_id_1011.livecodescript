script "stack_com.livecode.pi.colorwithalpha_scrollbar_id_1011"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.colorwithalpha.livecode
-- Object: stack "com.livecode.pi.colorwithalpha" > card (id 1002) > group "template" (id 1009) > group (id 1012) > scrollbar "Scrollbar" (id 1011)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag
   dispatch "valueChanged"
end scrollbarDrag
