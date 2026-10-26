script "stack_revPreferencesGUI_button_id_1412"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Automatic Updates" (id 1404) > button "checknow" (id 1412)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if not (the pendingmessages contains "tCheckForUpdates") then 
      set the cUpdateCheckSilent of stack "revPreferences" to false
      send tCheckForUpdates to card "Automatic Updates" of stack "revPreferencesGUI"
   end if
end mouseUp
