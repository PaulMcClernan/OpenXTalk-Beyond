script "stack_revStandaloneSettings_button_id_29876"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group (id 29881) > button "Add" (id 29876)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp pOverRide
   local tPrev
   ask "Please enter the URL to whitelist"
   if it is empty then
      exit mouseUp
   end if
   put fld "urlwhitelist" into tPrev
   if it is among the lines of tPrev then
      answer information "That URL is already included." with "OK"
      exit mouseUp
   end if
   put it into line (the number of lines in tPrev+1) of tPrev
   put tPrev into fld "urlwhitelist"
   storeSetting "urlwhitelist", tPrev
end mouseUp
