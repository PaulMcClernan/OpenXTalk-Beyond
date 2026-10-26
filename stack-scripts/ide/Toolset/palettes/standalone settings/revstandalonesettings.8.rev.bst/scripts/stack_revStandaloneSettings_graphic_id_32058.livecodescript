script "stack_revStandaloneSettings_graphic_id_32058"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Splash" (id 3538) > graphic "launch-backcolor" (id 32058)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   answer color with the backColor of me
   if the result is "cancel" then
      exit mouseUp
   end if
   storeSetting "launch-backcolor", it
   set the backColor of me to it
   set the opaque of me to true
   set the hilite of button "Use system background color" to false
end mouseUp
