script "stack_revPreferencesGUI_graphic_id_1521"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "UI Tweaks" (id 1512) > graphic "InspectorBkgnd Swatch" (id 1521)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   answer color
   if it is empty then -- canceled the dialog
      set the wholeMatches to true
      pass mousedown
   end if
   put it into theItem
   set the backgroundColor of graphic "InspectorBkgnd Swatch" to theItem -- name of this swatch
   set the label of btn "InspectorBkgnd" to "Other..."  -- name of the dropdown menu
   -- set the properties
   set the cInspectorBackgroundColor of stack "revPreferences" to theItem
   try
      if there is a stack "revPropertyInspector 1" then
         send updateInspector to stack "revPropertyInspector 1"
      end if
   end try
end mousedown
