script "stack_revStandaloneSettings_button_id_1140"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > group "Windows" (id 1169) > button "Use None2" (id 1140)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put empty into fld "documentIconFile"
  send closeField to fld "documentIconFile"
end mouseUp
