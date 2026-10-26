script "stack_revStandaloneSettings_field_id_1354"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > group "Windows" (id 1169) > group (id 1348) > field "fileversion4" (id 1354)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyDown pWhich
  if pWhich is not a number then
    beep
    exit keyDown
  end if
  pass keyDown
end keyDown
