script "stack_revRotate_field_id_1005"
-- Stack file: ide/Toolset/palettes/revrotate.livecode
-- Object: stack "revRotate" > card (id 1002) > field "Rotate" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keydown pKey
  if pKey is not a number then
    beep
    exit keyDown
  else pass keyDown
end keydown

on closeField
  if me > 360 then put 360 into me
  if me < 0 then put 0 into me
end closeField
