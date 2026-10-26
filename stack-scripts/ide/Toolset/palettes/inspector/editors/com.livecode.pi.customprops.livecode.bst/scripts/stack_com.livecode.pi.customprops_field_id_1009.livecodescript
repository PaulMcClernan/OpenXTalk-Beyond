script "stack_com.livecode.pi.customprops_field_id_1009"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.customprops.livecode
-- Object: stack "com.livecode.pi.customprops" > card (id 1002) > group "template" (id 1004) > field "key" (id 1009)
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
