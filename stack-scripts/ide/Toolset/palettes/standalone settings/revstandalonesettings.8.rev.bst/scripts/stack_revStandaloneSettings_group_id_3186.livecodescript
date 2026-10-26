script "stack_revStandaloneSettings_group_id_3186"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "In App Purchasing" (id 3173) > group "Samsung" (id 3182) > group (id 3186)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of button "Test Failure"of me then
      get -1
   else if the hilite of button "Production" of me then
      get 0
   else if the hilite of button "Test Success" of me then
      get 1
   end if
   storeSetting "samsungIapMode", it
   updateInAppPurchaseSettings
end mouseUp
