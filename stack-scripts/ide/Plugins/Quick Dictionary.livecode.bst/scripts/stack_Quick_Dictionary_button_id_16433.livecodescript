script "stack_Quick_Dictionary_button_id_16433"
-- Stack file: ide/Plugins/Quick Dictionary.livecode
-- Object: stack "Quick Dictionary" > card (id 1002) > button "AutoSearch" (id 16433)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp --auto-search
   set the visible of fld "Cerca" to the hilite of me
   if the hilite of me is true then
      set the visible of fld "Cerca" to false
      set the visible of fld "Cerca2" to true
      set the hilite of me to false
   else
      set the visible of fld "Cerca" to true
      set the visible of fld "Cerca2" to false
      set the hilite of me to true
   end if
   send "mouseUp" to btn "X"
   send tDelayedClick to me in 5 ticks
end mouseUp

on tDelayedClick
   put the loc of fld "Cerca2" into tClickLoc
   click at tClickLoc
end tDelayedClick
