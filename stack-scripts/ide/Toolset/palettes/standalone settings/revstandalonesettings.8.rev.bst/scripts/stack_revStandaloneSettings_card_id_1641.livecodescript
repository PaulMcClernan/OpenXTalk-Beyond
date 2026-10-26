script "stack_revStandaloneSettings_card_id_1641"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on opencard
   send hUpdateHeights to stack "revStandaloneSettingsbehavior" in 20 milliseconds
   pass opencard
end opencard

on preopencard
   send hUpdateHeights to stack "revStandaloneSettingsbehavior" in 20 milliseconds
   pass preopencard
end preopencard

