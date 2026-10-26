script "stack_revStandaloneSettings_field_id_1240"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Advanced Options" (id 2036) > group "moveSubstacks" (id 1260) > field "substackFolder" (id 1240)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on keyDown pWHich
  if pWhich is in ":/\*?<>|" then beep
  else pass keyDown
end keyDown

on closeField
  local tStackFiles,tStackFile
  put the hilitedStackFiles of fld "stackfiles" into tStackFiles
  repeat for each line tStackFile in tStackFiles
    set the cRevStandaloneSettings["substackFolder"] of stack tStackFile to me
    revSetEdit the short name of stack tStackFile
  end repeat
  revSetEdit
end closeField
