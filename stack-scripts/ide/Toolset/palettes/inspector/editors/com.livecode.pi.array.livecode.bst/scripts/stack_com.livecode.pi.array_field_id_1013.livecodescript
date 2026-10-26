script "stack_com.livecode.pi.array_field_id_1013"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.array.livecode
-- Object: stack "com.livecode.pi.array" > card (id 1002) > group "template" (id 1004) > field "key" (id 1013)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField
   doKeyChanged
end returnInField

on enterInField
   doKeyChanged
end enterInField

on closeField
   doKeyChanged
end closeField

on doKeyChanged
   send "keyChanged" to me in 0 millisecs
end doKeyChanged
