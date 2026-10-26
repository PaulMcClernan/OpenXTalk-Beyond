script "stack_revPreferencesGUI_graphic_id_1074"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > graphic "Backdrop Swatch" (id 1074)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   answer color
   if it is empty then -- canceled the dialog
      set the wholeMatches to true
      pass mousedown
   end if
   put it into theItem
   set the backgroundColor of graphic "Backdrop Swatch" to theItem
   set the label of btn "backdrop color" to "Other..." 
   if the backdrop is not "none" then set the backdrop to theItem
   set the cBackDropColor of stack "revPreferences" to theItem
   set the cBackDrop of stack "revPreferences" to theItem
end mousedown
