script "stack_revStandaloneSettings_button_id_3470"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 29811) > group "Basic Application Settings" (id 3462) > button "Profile" (id 3470)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   repeat for each element tElement in getProfiles()
      if tElement["index"] is the menuHistory of me then
         storeSetting "profile", tElement["id"]
         if tElement["days remaining"] < 45 then
            answer information "This profile will expire in " & tElement["days remaining"] & " days"
         end if
         exit repeat
      end if
   end repeat
end menuPick
