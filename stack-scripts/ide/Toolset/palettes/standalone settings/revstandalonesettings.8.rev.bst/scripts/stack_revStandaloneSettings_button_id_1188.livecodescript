script "stack_revStandaloneSettings_button_id_1188"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Bug Reports" (id 1017) > group "errorDialog" (id 1190) > button "email1" (id 1188)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
  set the enabled of group "email" to the hilite of me
  if not the hilite of me then 
    put "" into fld "email" 
    send "closeField" to fld "email"
  end if
end mouseup
