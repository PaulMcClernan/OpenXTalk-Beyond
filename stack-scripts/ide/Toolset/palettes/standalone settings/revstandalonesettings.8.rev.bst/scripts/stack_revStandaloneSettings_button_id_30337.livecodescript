script "stack_revStandaloneSettings_button_id_30337"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "buildbutton" (id 30346) > button "Build for iOS" (id 30337)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cRevStandaloneSettings["ios"] of stack the cRevTargetStack of this stack to the hilite of button 1 of me
   if the hilite of button 1 of me then
      buildForEnabled "ios"
   end if
   revSetEdit
   updateIosSettingState
end mouseUp
