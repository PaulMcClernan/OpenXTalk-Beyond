script "stack_Report_Builder_button_id_1018"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > group "Font & Text Size" (id 1019) > button "Font" (id 1018)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pPick  --choose font
   if pPick is among the lines of fontNames() then set the textFont of fld "Text" of stack "Report" to pPick  --substack
end menuPick
