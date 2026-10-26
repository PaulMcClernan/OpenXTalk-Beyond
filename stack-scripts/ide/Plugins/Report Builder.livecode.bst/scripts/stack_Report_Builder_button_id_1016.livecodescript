script "stack_Report_Builder_button_id_1016"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > group "Font & Text Size" (id 1019) > button "TextSize" (id 1016)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pPick  --report textsize
   set the textSize of fld "Text" of stack "Report" to pPick  --substack
end menuPick

on closeField  --user enters report textsize
   set the textSize of fld "Text" of stack "Report" to the selectedText of me
end closeField
