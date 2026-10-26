script "stack_revPreferencesGUI_button_id_1149"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Variable Checking" (id 1149)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   if the hilite of me is true then
      Answer "<b>Are you sure you want to turn this on?</b><br> <br>" & return &¬
      "Turning on 'Strict Compilation Mode' is likely to break several parts of the IDE. It's best to keep this turned off if you are unsure." with "Turn on" or "Leave off"
      if it is "Leave Off" then
         --set the cVariableChecking of stack "revPreferences" to false
         set the hilite of me to false
      end if
      if it is "Turn On" then
         --set the cVariableChecking of stack "revPreferences" to true
         set the hilite of me to true
      end if
   else
      set the hilite of me to false
      --
   end if
end mouseup
