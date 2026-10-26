script "stack_revPreferencesGUI_button_id_1518"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "UI Tweaks" (id 1512) > button "labelsections size" (id 1518)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
   if theitem contains "Default" then
      set the label of me to "Default"
      set the cInspectorLabelSize of stack "revPreferences" to ""
      exit menuPick
   end if
   set the cInspectorLabelSize of stack "revPreferences" to theItem
end menuPick
