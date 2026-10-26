script "stack_revStandaloneSettings_group_id_30345"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "iOS Settings" (id 30345)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on opencControl
put the name of this card
      send hUpdateHeights to stack "revStandaloneSettingsbehavior" in 10 milliseconds

end opencControl
