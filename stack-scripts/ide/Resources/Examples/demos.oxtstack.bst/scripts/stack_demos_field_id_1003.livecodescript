script "stack_demos_field_id_1003"
-- Stack file: ide/Resources/Examples/demos.oxtstack
-- Object: stack "demos" > card (id 1002) > field "pickList" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   send checkDemoStack to button "Open" of this card
   pass mousedown
end mousedown
