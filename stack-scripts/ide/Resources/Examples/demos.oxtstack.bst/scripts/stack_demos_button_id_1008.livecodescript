script "stack_demos_button_id_1008"
-- Stack file: ide/Resources/Examples/demos.oxtstack
-- Object: stack "demos" > card (id 1002) > button "Close" (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   set the destroyStack of this stack to true
   close this stack
end mousedown
