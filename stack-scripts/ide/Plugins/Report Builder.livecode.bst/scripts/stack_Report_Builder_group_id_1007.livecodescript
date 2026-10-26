script "stack_Report_Builder_group_id_1007"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > card (id 1002) > group "Margins" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --report margins
   local tPosition, tMargins
   focus on nothing  --remove dotted outline of selected btn
   put the topLeft of stack "Report" into tPosition  --substack
   lock screen
   if the hilite of btn "HalfInch" of grp "Margins" then put "72" into tMargins  --36+36px
   else  if the hilite of btn "Inch" of grp "Margins" then put "144" into tMargins  --72+72px
   if the hilite of btn "Letter" of grp "Size" then  --612x792px
      set the width of stack "Report" to 612-tMargins
      set the height of stack "Report" to 792-tMargins
   else if the hilite of btn "A4" of grp "Size" then  --595x842px
      set the width of stack "Report" to 595-tMargins
      set the height of stack "Report" to 842-tMargins
   end if
   set the topLeft of stack "Report" to tPosition  --reposition
end mouseUp
