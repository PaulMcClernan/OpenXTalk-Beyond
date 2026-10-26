script "stack_revStandaloneSettings_group_id_1086"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "OS X" (id 1015) > group "Flavors" (id 1086)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   put false into tEnable
   put "" into tbtns
   -- we turn off the universal arm button
   set the hilite of btn "MacOS-IntelArmUniversal" to false
   set the cRevStandaloneSettings["MacOSX x64-ARM64"] of stack (the cRevTargetStack of this stack) to false
   --
   repeat with x=1 to the number of btns of me
      if the hilite of btn X of me then
         if not(the short name of btn X of me is "MacOS-IntelArmUniversal") then
            put revDownloadEngine(the cSettingTag of btn X of me) into tEnable
            if not tEnable then set the hilite of btn X of me to false
         end if
         set the cRevStandaloneSettings[the cSettingTag of btn X of me] of stack (the cRevTargetStack of this stack) to the hilite of btn X of me
         
      end if
   end repeat
   set the enabled of group "OSX" to tEnable
   
   -- however!
   if the hilite of button "MacOS-IntelArmUniversal" is false then
      set the cRevStandaloneSettings["MacOSX x64-ARM64"] of stack the cRevTargetStack of this stack to false
      
      if the hilite of button "MacOSX x86-64" is false then
         if the hilite of button "MacOSX x86-32" is false then
            -- all buttons are off
            set the visible of button "OSXchecked" of group "checks" of stack "revStandaloneSettings" to false
            set the cRevStandaloneSettings["MacOSX x86-32"] of stack the cRevTargetStack of this stack to false
            set the cRevStandaloneSettings["MacOSX x86-64"] of stack the cRevTargetStack of this stack to false
            set the cRevStandaloneSettings["MacOSX x64-ARM64"] of stack the cRevTargetStack of this stack to false
         end if
      end if
   end if
   
   
   if the hilite of button "MacOS-IntelArmUniversal" is true then
      set the cRevStandaloneSettings["MacOSX x64-ARM64"] of stack the cRevTargetStack of this stack to true
   end if
   
   buildForEnabled "MacOSX"
   revSetEdit
   if not (the pendingmessages contains "opencard") then send opencard to this card in 20 milliseconds
end mouseUp

