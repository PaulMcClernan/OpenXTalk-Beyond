script "stack_com.livecode.pi.script_field_id_1008"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.script.livecode
-- Object: stack "com.livecode.pi.script" > card (id 1002) > group "template" (id 1007) > field "Field" (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField
   dispatch "valueChanged"
end returnInField

on enterInField
   dispatch "valueChanged"
end enterInField

on closeField
   dispatch "valueChanged"
end closeField
