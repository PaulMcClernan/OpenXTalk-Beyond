script "stack_revStandaloneSettings_button_id_32077"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Splash" (id 3538) > button "Use system background color" (id 32077)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me then
      storeSetting "launch-backcolor", empty
      set the opaque of graphic "launch-backcolor" to false
   else
      storeSetting "launch-backcolor", "0,0,0"
      set the backColor of graphic "launch-backcolor" to 0,0,0
      set the opaque of graphic "launch-backcolor" to true
   end if
end mouseUp
