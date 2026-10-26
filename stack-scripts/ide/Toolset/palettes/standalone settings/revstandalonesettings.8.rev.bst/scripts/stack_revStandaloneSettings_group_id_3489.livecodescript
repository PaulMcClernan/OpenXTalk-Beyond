script "stack_revStandaloneSettings_group_id_3489"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 29811) > group "User Interface Options" (id 3483) > group "iPad Initial Orientations" (id 3489)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if word 1 of the name of the target is not "button" then
      exit mouseUp
   end if
   
   local tOld, tNew
   put fetchSetting("ipad intial orientations") into tOld
   put empty into tNew
   repeat for each item tItem in tOld
      if tItem is not the short name of the target then
         put tItem & comma after tNew
      end if
   end repeat
   if the hilite of the target then
      put the short name of the target & comma after tNew
   end if
   
   -- MM-2011-09-29: Make sure we have atleast one supported oreintation.
   --
   --   if tNew is empty then
   --      put "Portrait" into tNew
   --      set the hilite of button "Portrait" of me to true
   --   end if
   
   storeSetting "ipad intial orientations", tNew
   updateOrientationSettings
end mouseUp
