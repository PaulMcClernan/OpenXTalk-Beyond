script "stack_revStandaloneSettings_button_id_3193"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "In App Purchasing" (id 3173) > button "In App Purchasing" (id 3193)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "inAppPurchasing", the hilite of me
   updateInAppPurchaseSettings
end mouseUp
