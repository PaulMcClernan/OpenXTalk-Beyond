script "stack_revPreferencesGUI_graphic_id_1075"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > graphic "Selection Handle Swatch" (id 1075)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   answer color
   if it is empty then -- canceled the dialog
      set the wholeMatches to true
      pass mousedown
   end if
   put it into theItem
   set the backgroundColor of graphic "Selection Handle Swatch" to theItem -- name of this swatch
   set the label of btn "selectionhandle color" to "Other..."  -- name of the dropdown menu
   -- set the properties
   set the backgroundColor of graphic "Selection Handle Swatch" to theItem
   set the selectionHandleColor to theItem
   set the cSelectionHandleColor of stack "revPreferences" to theItem
end mousedown

