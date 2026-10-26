script "stack_com.livecode.pi.dimension_field_id_1003"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.dimension.livecode
-- Object: stack "com.livecode.pi.dimension" > card (id 1002) > group "template" (id 1004) > field "Field" (id 1003)
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
