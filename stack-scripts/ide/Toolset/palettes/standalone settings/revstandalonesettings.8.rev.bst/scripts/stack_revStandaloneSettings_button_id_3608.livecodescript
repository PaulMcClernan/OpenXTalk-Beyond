script "stack_revStandaloneSettings_button_id_3608"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "iOS Settings" (id 30345) > group (id 30343) > button "Supported Devices" (id 3608)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   switch pItemName
      case "iPod, iPhone and iPad"
         get 1,2
         break
      case "iPod and iPhone"
         get 1
         break
      case "iPad"
         get 2
         break
   end switch
   enableDeviceSpecificSettings it
   storeSetting "device family", it
   updateOrientationSettings
end menuPick
