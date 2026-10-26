script "stack_revPreferencesGUI_graphic_id_1515"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "UI Tweaks" (id 1512) > graphic "Inspector Sections Swatch" (id 1515)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   answer color
   if it is empty then -- canceled the dialog
      set the wholeMatches to true
      pass mousedown
   end if
   put it into theItem
   set the backgroundColor of graphic "Inspector Sections Swatch" to theItem -- name of this swatch
   set the label of btn "labelsections color" to "Other..."  -- name of the dropdown menu
   -- set the properties
   set the backgroundColor of graphic "Inspector Sections Swatch" to theItem
   set the cInspectorLabelColor of stack "revPreferences" to theItem
end mousedown

