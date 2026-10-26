script "stack_revStandaloneSettings_button_id_1237"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Advanced Options" (id 2036) > button "moveSubstacks" (id 1237)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tStackFiles,tStackFile
  put the hilitedStackFiles of fld "stackfiles" into tStackFiles
  repeat for each line tStackFile in tStackFiles
    set the cRevStandaloneSettings["moveSubstacks"] of stack tStackFile to the hilite of me
    revSetEdit the short name of stack tStackFile
  end repeat
  set the enabled of group "moveSubstacks" to the hilite of me
end mouseUp
