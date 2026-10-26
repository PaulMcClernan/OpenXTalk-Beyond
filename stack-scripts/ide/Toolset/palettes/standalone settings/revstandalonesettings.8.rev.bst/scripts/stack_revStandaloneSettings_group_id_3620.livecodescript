script "stack_revStandaloneSettings_group_id_3620"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 3461) > group (id 3616) > group "Device Capabilities" (id 3620)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- MM-2012-03-07: [[ BUG 10060 ]] Make sure all requirements are checked
   local tArray
   repeat with i = 1 to 18
      get the short name of group i of me
      if the hilite of button 1 of group i of me then
         put "true" into tArray[it]
      else if the hilite of button 2 of group i of me then
         put "false" into tArray[it]
      end if
   end repeat
   storeSetting "device capabilities", tArray
   updateSettings
end mouseUp
