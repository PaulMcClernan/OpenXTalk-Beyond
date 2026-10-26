script "stack_revPreferencesGUI_button_id_1248"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Compatibility" (id 1015) > group "Compatibility Options" (id 1247) > button "disPlayerLin" (id 1248)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of cd btn "success" is false then
      -- dependencies not met
      set the hilite of me to true
      set the cDisablePlayerTool of stack "revPreferences" to true -- disable player tool
      Answer "Sorry, dependencies not met" with "More info" or "Ok"
      if it is "More info" then
         send doInstructions to button "Success"
      end if
      exit mouseup
   end if
   
   -- OXT-Beyond: as a preference, so that it is saved at once and the
   -- Tools palette shows or hides the tool (revtools)
   if the hilite of me is true then
      set the hilite of me to false
      revIDESetPreference "cDisablePlayerTool", false -- enable player tool
   else
      set the hilite of me to true
      revIDESetPreference "cDisablePlayerTool", true -- disable player tool
   end if
   
end mouseUp

on tryEnablePlayer
   if the hilite of cd btn "success" is false then
      -- dependencies not met
      set the hilite of me to true
      set the cDisablePlayerTool of stack "revPreferences" to true -- disable player tool
      Answer "Sorry, dependencies not met" with "More info" or "Ok"
      if it is "More info" then
         send doInstructions to button "Success"
      end if
      exit tryEnablePlayer
   end if
   set the hilite of me to false
   -- OXT-Beyond: as the check box does it (mouseUp)
   revIDESetPreference "cDisablePlayerTool", false -- enable player tool
   
end tryEnablePlayer
