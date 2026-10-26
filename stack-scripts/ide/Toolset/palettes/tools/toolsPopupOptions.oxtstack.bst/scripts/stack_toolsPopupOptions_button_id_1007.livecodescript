script "stack_toolsPopupOptions_button_id_1007"
-- Stack file: ide/Toolset/palettes/tools/toolsPopupOptions.oxtstack
-- Object: stack "toolsPopupOptions" > card (id 1002) > group "tBtnOptions" (id 1009) > button "paint-controls" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   if the hilite of me is false then
      set the hilite of me to true
   else
      set the hilite of me to false
   end if
end mouseup
