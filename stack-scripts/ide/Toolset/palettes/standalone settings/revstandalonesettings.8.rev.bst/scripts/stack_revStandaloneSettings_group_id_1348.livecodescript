script "stack_revStandaloneSettings_group_id_1348"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > group "Windows" (id 1169) > group (id 1348)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown x
  if the length of the text of the target < the cLength[the short name of the target] of this stack \
      or the short name of the target contains "version" or \
      the selectedText of the target <> "" then pass keyDown
end keyDown
