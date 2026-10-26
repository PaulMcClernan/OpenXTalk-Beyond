script "stack_Mobile_Browser_Example_field_id_1009"
-- Stack file: ide/Resources/Mobile Examples/Browser Example.livecode
-- Object: stack "Mobile Browser Example" > card (id 1002) > field "URL" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
   goUrl the text of me
end closeField

on returnInField
   focus on nothing
end returnInField
