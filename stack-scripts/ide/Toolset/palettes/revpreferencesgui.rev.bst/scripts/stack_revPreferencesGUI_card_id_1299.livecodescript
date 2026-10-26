script "stack_revPreferencesGUI_card_id_1299"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Updates" (id 1299)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   local tEnable
   -- PM-2015-05-14: [Bug 15367] Make sure we use the correct names of custom property keys (as found in installer.rev stack)
   
   ## Set boolean defaults for the preference, a checkbox cannot be set to empty
   if revIDEGetPreference("cNotifyMeOfStableReleases") is empty then revIDESetPreference "cNotifyMeOfStableReleases",true
   if revIDEGetPreference("cNotifyMeOfMaintainenceReleases") is empty then revIDESetPreference "cNotifyMeOfMaintainenceReleases",true
   if revIDEGetPreference("cNotifyMeOfBetaReleases") is empty then revIDESetPreference "cNotifyMeOfBetaReleases",true
   if revIDEGetPreference("cNotifyMeOfDevelopmentReleases") is empty then revIDESetPreference "cNotifyMeOfDevelopmentReleases",true
   
   set the hilite of button "Notify me of stable releases" to revIDEGetPreference("cNotifyMeOfStableReleases")
   set the hilite of button "Notify me of maintainence releases" to revIDEGetPreference("cNotifyMeOfMaintainenceReleases")
   set the hilite of button "Notify me of beta releases" to revIDEGetPreference("cNotifyMeOfBetaReleases") 
   set the hilite of button "Notify me of development releases" to revIDEGetPreference("cNotifyMeOfDevelopmentReleases") 
   
   set the enabled of  button "Notify me of stable releases" of cd "Updates" to true
   set the enabled of  button "Notify me of maintainence releases" of cd "Updates" to true
   set the enabled of  button "Notify me of beta releases" of cd "Updates" to true
   set the enabled of  button "Notify me of development releases" of cd "Updates" to true
end preOpenCard
