script "stack_revStandaloneSettings_button_id_1301"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "OS X" (id 1015) > group "OSX" (id 1221) > button "Choose file" (id 1301)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cCurrentIcon of stack "revIconChooser" to fld "appicon"
  sheet "revIconChooser"
  if the cReturnValue of stack "revIconChooser" is not empty then
    put the cReturnValue of stack "revIconChooser" into fld "appicon"
    send "closeField" to fld "appicon"
  end if
end mouseUp
