script "stack_revPreferencesGUI_button_id_1510"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > button "hAskSuppress" (id 1510)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me is true then
      set the hilite of me to false
      set the cPromptToggleMsgSuppress of stack "revPreferences" to false
   else
      set the hilite of me to true
      set the cPromptToggleMsgSuppress of stack "revPreferences" to true
   end if
   
end mouseUp
