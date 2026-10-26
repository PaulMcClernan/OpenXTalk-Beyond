script "stack_revStandaloneSettings_button_id_4146"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group "Reqs" (id 29852) > button "Disable ATS" (id 4146)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me then
      answer "App Transport Security protects you and users' data from modification and interception by enforcing secure connection. It is recommended to leave it enabled, and provide HTTPS access to your back-end services." with "Disable" or "Cancel" titled "Are you sure you want to disable ATS?"
      
      if it is "Cancel" then
         set the hilite of me to false
      end if
   end if
   
    storeSetting "disable ATS", the hilite of me
end mouseUp
