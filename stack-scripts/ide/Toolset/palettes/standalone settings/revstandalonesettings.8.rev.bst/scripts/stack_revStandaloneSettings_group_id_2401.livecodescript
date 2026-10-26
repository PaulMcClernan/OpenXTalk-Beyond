script "stack_revStandaloneSettings_group_id_2401"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Application Permissions" (id 2352) > group "permissions" (id 2401)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tArray
   repeat with i = 1 to the number of buttons of me
      get the short name of button i of me
      if the hilite of button i of me then
         put "true" into tArray[it]
      end if
   end repeat
   storeSetting "application permissions", tArray
end mouseUp
