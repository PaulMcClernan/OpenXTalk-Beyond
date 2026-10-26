script "stack_updater_button_id_1015"
-- Stack file: ide/Toolset/palettes/updates/updates.livecode
-- Object: stack "updater" > card (id 1002) > button "insecure" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   if the hilite of me is true then
      set the hilite of me to false
      opencard
   else
      set the hilite of me to true
      opencard
   end if
end mousedown
