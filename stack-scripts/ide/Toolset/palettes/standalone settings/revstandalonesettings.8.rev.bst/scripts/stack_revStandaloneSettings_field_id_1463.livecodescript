script "stack_revStandaloneSettings_field_id_1463"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Copy Files" (id 1027) > group (id 1466) > group "Destination Group" (id 1467) > field "Destination" (id 1463)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  checkField
end closeField

on returnInField
  checkField
end returnInField

on tabKey
  checkField
end tabKey

on checkField
  -- Checks here should be improved.
  if the text of me is empty then
    answer "Cannot set the destination folder to empty, reverting to default."
    put "_ReferencedFiles" into me
  end if
  setProps
end checkField




