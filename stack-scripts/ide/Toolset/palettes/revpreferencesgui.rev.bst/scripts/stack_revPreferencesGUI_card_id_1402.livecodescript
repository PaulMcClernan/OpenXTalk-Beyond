script "stack_revPreferencesGUI_card_id_1402"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Extras" (id 1402)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   lock screen
   -- check if layout guides at startup is turned on (tperry 09-11-2023)
   if the cLayoutGuides of stack "revPreferences" is true then
      set the hilite of btn "useLayoutGuides" of card "Extras" of stack "revPreferencesGUI" to true
   else
      set the hilite of btn "useLayoutGuides" of card "Extras" of stack "revPreferencesGUI" to false
   end if
   ---------------
   -- check if tidyUpStacks is turned on or off (tperry 3-12-23)
   if the cTidyUpStacks of stack "revPreferences" is true then
      set the hilite of btn "tidyUpStacks" of card "Extras" of stack "revPreferencesGUI" to true
   else
      set the hilite of btn "tidyUpStacks" of card "Extras" of stack "revPreferencesGUI" to false
   end if
   
   -- screensharedMemory
   if the platform contains "linux" then
      enable btn "ScreenSharedMemory" of card "Extras" of stack "revPreferencesGUI"
   else
      disable btn "ScreenSharedMemory" of card "Extras" of stack "revPreferencesGUI"
   end if
   if the cScrnSharedMem of stack "revPreferences" is true then
      set the hilite of btn "ScreenSharedMemory" of card "Extras" of stack "revPreferencesGUI" to true
   else
      set the hilite of btn "ScreenSharedMemory" of card "Extras" of stack "revPreferencesGUI" to false
   end if
   
   
   unlock screen
end preOpenCard

