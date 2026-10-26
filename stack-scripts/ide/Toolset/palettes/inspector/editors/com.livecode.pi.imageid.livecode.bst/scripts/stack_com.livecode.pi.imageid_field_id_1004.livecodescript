script "stack_com.livecode.pi.imageid_field_id_1004"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.imageid.livecode
-- Object: stack "com.livecode.pi.imageid" > card (id 1002) > group "template" (id 1009) > field "value" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keydown pKey
  if pKey is not a number then
    beep
    exit keyDown
  else pass keyDown
end keydown
