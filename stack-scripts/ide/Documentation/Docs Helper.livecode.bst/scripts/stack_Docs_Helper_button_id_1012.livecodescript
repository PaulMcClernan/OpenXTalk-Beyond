script "stack_Docs_Helper_button_id_1012"
-- Stack file: ide/Documentation/Docs Helper.livecode
-- Object: stack "Docs Helper" > card (id 1002) > button "Test" (id 1012)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   dispatch "validateEntry" to stack "LibrarySubstack" with field "Text"
   showErrors the result
end mouseUp
