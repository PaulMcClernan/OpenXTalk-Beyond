script "stack_revStandaloneSettings_group_id_2268"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Requirements and Restrictions" (id 2255) > group "device requirements" (id 2264) > group "Device Capabilities" (id 2268)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sLinkedPermissions = "hardware.microphone,RECORD_AUDIO|hardware.location.gps,ACCESS_FINE_LOCATION|hardware.location.network,ACCESS_COARSE_LOCATION|hardware.camera,CAMERA"

on mouseUp
   local tArray
   local tPermissions
   
   repeat with i = 1 to the number of groups of me
      get the short name of group i of me
      if the hilite of button 1 of group i of me then
         put "true" into tArray[it]
      else if the hilite of button 2 of group i of me then
         put "false" into tArray[it]
      end if
   end repeat
   #set the linedelimiter to "|"
   #repeat for each line tLine in sLinkedPermissions
   #   if tArray[item 1 of tLine] is not empty then
   #      put true into tPermissions[item 2 of tLine]
   #   end if
   #end repeat
   storeSetting "device capabilities", tArray
   #storeSetting "capability permissions", tPermissions
end mouseUp
