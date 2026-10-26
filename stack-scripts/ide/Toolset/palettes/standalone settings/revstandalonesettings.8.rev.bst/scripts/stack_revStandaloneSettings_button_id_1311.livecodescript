script "stack_revStandaloneSettings_button_id_1311"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Bug Reports" (id 1017) > group "errorDialog" (id 1190) > button "Choose file" (id 1311)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cCurrentIcon of stack "revIconChooser" to fld "icon"
  sheet "revIconChooser"
  if the cReturnValue of stack "revIconChooser" is not empty then
    put the cReturnValue of stack "revIconChooser" into fld "icon"
    send "closeField" to fld "icon"
  end if
end mouseUp
