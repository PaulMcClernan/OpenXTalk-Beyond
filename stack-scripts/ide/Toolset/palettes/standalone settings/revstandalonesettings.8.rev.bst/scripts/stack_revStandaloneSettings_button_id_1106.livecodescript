script "stack_revStandaloneSettings_button_id_1106"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "OS X" (id 1015) > group "OSX" (id 1221) > group "choose" (id 1284) > button "Use None2" (id 1106)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put empty into fld "plist"
  send closeField to fld "plist"
end mouseUp
