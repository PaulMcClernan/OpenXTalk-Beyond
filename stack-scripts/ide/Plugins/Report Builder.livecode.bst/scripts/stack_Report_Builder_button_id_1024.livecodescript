script "stack_Report_Builder_button_id_1024"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > button "Page Break" (id 1024)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sCursor  --script local, available to handlers below
on mouseEnter  --capture cursor position
   put selectedChunk(fld 1 of stack "Report") into sCursor  --char x to y of fld z
end mouseEnter

on mouseUp  --insert page break expression
   if sCursor = empty then
      answer "Please place cursor in a blank line of text first." with "OK" titled "Insert Page Break"
      exit to top
   end if
   do "put" &&quote& "<%formfeed%>" &quote&& "into" && sCursor && "of stack" &&quote& "Report" &quote
end mouseUp
