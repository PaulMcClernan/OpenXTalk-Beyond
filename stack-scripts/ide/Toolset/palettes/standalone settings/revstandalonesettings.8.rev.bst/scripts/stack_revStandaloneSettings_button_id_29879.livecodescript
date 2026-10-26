script "stack_revStandaloneSettings_button_id_29879"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group (id 29881) > button "Remove Entry" (id 29879)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tLines
   if the hilitedLines of fld "urlwhitelist" is not empty then
      put the hilitedLines of fld "urlwhitelist" into tLines
      repeat with X=the number of items in tLines down to 1
         delete line (item X of tLines) of fld "urlwhitelist"
      end repeat
      storeSetting "urlwhitelist", fld "urlwhitelist"
   end if
end mouseUp
