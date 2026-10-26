script "stack_toolsPopupOptions_button_id_1029"
-- Stack file: ide/Toolset/palettes/tools/toolsPopupOptions.oxtstack
-- Object: stack "toolsPopupOptions" > card (id 1002) > group "tBtnOptions" (id 1009) > button "sectionNames" (id 1029)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   if the hilite of button "sectionNames" is false then
      set the hilite of me to true
      set the cToolsSectionNames of stack "revPreferences" to true
   else
      set the hilite of me to false
      set the cToolsSectionNames of stack "revPreferences" to false
   end if
end mouseup
