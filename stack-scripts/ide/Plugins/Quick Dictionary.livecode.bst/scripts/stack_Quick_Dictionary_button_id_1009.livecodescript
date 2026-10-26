script "stack_Quick_Dictionary_button_id_1009"
-- Stack file: ide/Plugins/Quick Dictionary.livecode
-- Object: stack "Quick Dictionary" > card (id 1002) > button "X" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of btn "AutoSearch" then  --auto-search
      put empty into fld "Cerca"
      select text of fld "Cerca"
   else  --traditional search
      put empty into fld "Cerca2"
      select text of fld "Cerca2"
   end if
   put "" into fld "testo"
   set the dgText of grp "Risultati" to ""
   
end mouseUp
