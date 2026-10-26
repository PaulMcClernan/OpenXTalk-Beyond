script "stack_Quick_Dictionary_button_id_5883"
-- Stack file: ide/Plugins/Quick Dictionary.livecode
-- Object: stack "Quick Dictionary" > card (id 1002) > button "All" (id 5883)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local temp
   lock screen
   put the number of buttons of group "filtro" into temp
   get not the hilite of button 1 of grp "filtro"  --opposite
   repeat with i = 1 to temp
      set the hilite of button i of group "filtro" to it  --true/false
   end repeat
   send "TextChanged" to fld "Cerca"  --update
end mouseUp
