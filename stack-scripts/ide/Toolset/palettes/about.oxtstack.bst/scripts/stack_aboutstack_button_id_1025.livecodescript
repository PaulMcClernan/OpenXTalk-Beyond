script "stack_aboutstack_button_id_1025"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack" > card (id 1013) > group "licbtns" (id 1015) > button "LibBZip2 License" (id 1025)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put the theBlurb of me into tNewText
   set the text of fld "ttext" to tNewText
   hide group "licbtns"
   show fld "ttext"
end mousedown
