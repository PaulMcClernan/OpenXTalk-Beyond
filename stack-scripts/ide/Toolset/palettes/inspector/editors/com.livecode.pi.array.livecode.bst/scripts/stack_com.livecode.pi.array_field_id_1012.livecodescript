script "stack_com.livecode.pi.array_field_id_1012"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.array.livecode
-- Object: stack "com.livecode.pi.array" > card (id 1002) > group "template" (id 1004) > field "value" (id 1012)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on enterInField
   doValueChanged
end enterInField

on returnInField
   if (the controlKey is down) then 
      doValueChanged
   else
      pass returnInField
   end if
end returnInField

on closeField
   doValueChanged
end closeField

on doValueChanged
   send "valueChanged" to me in 0 millisecs
end doValueChanged
