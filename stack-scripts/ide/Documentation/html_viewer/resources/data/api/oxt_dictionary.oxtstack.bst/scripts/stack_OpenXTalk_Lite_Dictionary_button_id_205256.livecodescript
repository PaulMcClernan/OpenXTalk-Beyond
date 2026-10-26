script "stack_OpenXTalk_Lite_Dictionary_button_id_205256"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > button "langdatagrid" (id 205256)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   set the hilite of me to true
   --
   set the hilite of btn "langxtalk" to false
   set the hilite of btn "langbuilder" to false
   --set the hilite of btn "langdatagrid" to false
   --
   opencard
end mousedown

