script "stack_revStandaloneSettings_group_id_1266"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > group "platforms" (id 1266)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tEnable
   put false into tEnable
   repeat with x = 1 to the number of buttons of me
      if the hilite of button x of me then
         put revDownloadEngine(the short name of button x of me) into tEnable
         if not tEnable then
            set the hilite of button x of me to false
         end if
      end if
      set the cRevStandaloneSettings[the short name of button x of me] of stack the cRevTargetStack of this stack to the hilite of button x of me
   end repeat
   buildForEnabled "Windows"
   revSetEdit
   uacUpdateUIStatus
   checkUUID
   set the enabled of group "Windows" to tEnable 
end mouseUp
