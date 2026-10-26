script "stack_revStandaloneSettings_group_id_31523"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Targets" (id 31523)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if word 1 of the target is not "button" then
      exit mouseUp
   end if
   
   local tTarget
   put the short name of the target into tTarget
   updateAndroidArch word 2 of tTarget, the hilite of the target
end mouseUp
