script "stack_revStandaloneSettings_button_id_32754"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "OS X" (id 1015) > group "Flavors" (id 1086) > button "MacOS-IntelArmUniversal" (id 32754)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   set the cSettingTag of me to "MacOSX x64-ARM64"
   put the hilite of me into tStandaloneSettingsA["MacOSX x64-ARM64"]

   -- turn off the other two MacOS build options
   set the hilite of button "MacOSX x86-32" to false
   set the hilite of button "MacOSX x86-64" to false
   set the cRevStandaloneSettings["MacOSX x86-32"] of stack the cRevTargetStack of this stack to false
   set the cRevStandaloneSettings["MacOSX x86-64"] of stack the cRevTargetStack of this stack to false

   put (the cRevTargetStack of this stack) into myStack
   if the hilite of me is true then
      if the enabled of me is true then
         -- okay, we are all good
         set the visible of button "OSXchecked" of group "checks" of stack "revStandaloneSettings" to true
         set the enabled of button "OS X" of group "cards" to true
         set the enabled of group "OSX" to true
         set the cRevStandaloneSettings["MacOSX x64-ARM64"] of stack myStack to true

      end if
   else
      set the visible of button "OSXchecked" of group "checks" of stack "revStandaloneSettings" to false
      set the enabled of group "OSX" to false
      set the cRevStandaloneSettings["MacOSX x64-ARM64"] of stack myStack to false
   end if
end mouseup
