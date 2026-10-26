script "stack_aboutstack_button_id_1009"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack" > card "id 1002" (id 1002) > button "Open Source License" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   set cursor to watch
   go cd 2
   /*
   set the itemDelimiter to "/"
   put item 1 to -3 of the filename of stack "home" & "/Open Source Licenses.txt" into tFilePath
   put textDecode(url ("binfile:" & tFilePath), "utf-8") into tLegaltext
   put tLegaltext into fld "ttext"
   */
   
end mousedown
