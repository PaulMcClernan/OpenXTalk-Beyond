script "stack_revPreferencesGUI_button_id_1516"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "UI Tweaks" (id 1512) > button "labelsections bold" (id 1516)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me is true then
      set the cInspectorLabelBold of stack "revPreferences" to true
   else
      set the cInspectorLabelBold of stack "revPreferences" to false
   end if
end mouseUp
