script "stack_revPreferencesGUI_card_id_1512"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "UI Tweaks" (id 1512)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopencard
   put the cInspectorLabelColor of stack "revPreferences" into theItem
   if theItem is "" then
      -- we set to default
      set the label of button "labelsections color" to "Default"
      set the backgroundColor of graphic "Inspector Sections Swatch" to ""
   else
      set the backgroundColor of graphic "Inspector Sections Swatch" to theItem
      set the label of button "labelsections color" to theItem
   end if
   --
   if the cInspectorLabelBold of stack "revPreferences" is true then
      set the hilite of btn "labelsections bold" to true
   else
      set the hilite of btn "labelsections bold" to false
   end if
   --
   if the cInspectorLabelSize of stack "revPreferences" is not "" then
      set the label of btn "labelsections size" to the cInspectorLabelSize of stack "revPreferences"
   else
      set the label of btn "labelsections size" to "Default"
      set the cInspectorLabelSize of stack "revPreferences" to ""
   end if
   --
   if the cInspectorBackgroundColor of stack "revPreferences" is not "" then
      set the label of btn "inspectorBkgnd" to the cInspectorBackgroundColor of stack "revPreferences"
      set the backgroundColor of graphic "InspectorBkgnd Swatch" to the cInspectorBackgroundColor of stack "revPreferences"
      
   else
      set the label of btn "inspectorBkgnd" to "Default"
      set the cInspectorBackgroundColor of stack "revPreferences" to ""
      set the backgroundColor of graphic "InspectorBkgnd Swatch" to ""
      
   end if
   --
end preopencard
