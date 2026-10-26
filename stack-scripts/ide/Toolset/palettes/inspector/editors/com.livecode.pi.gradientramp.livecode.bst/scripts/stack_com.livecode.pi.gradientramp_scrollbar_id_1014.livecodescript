script "stack_com.livecode.pi.gradientramp_scrollbar_id_1014"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.gradientramp.livecode
-- Object: stack "com.livecode.pi.gradientramp" > card (id 1002) > group "template" (id 1008) > group "color" (id 1012) > group (id 1013) > scrollbar "alpha" (id 1014)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag
   dispatch "valueChanged"
end scrollbarDrag
