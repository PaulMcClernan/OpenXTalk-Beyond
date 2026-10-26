script "stack_revStandaloneSettings_group_id_3178"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "In App Purchasing" (id 3173) > group "Store" (id 3176) > group (id 3178)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   if the hilite of button  "Google" of me then
      get "Google"
   else if the hilite of button "Amazon" of me then
      get "Amazon"
   else if the hilite of button "Samsung" of me then
      get "Samsung"
   end if
   storeSetting "billingProvider", it
   updateInAppPurchaseSettings
end mouseup
