script "stack_revStandaloneSettings_button_id_1239"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Advanced Options" (id 2036) > group "moveSubstacks" (id 1260) > button "Data stacks directory" (id 1239)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tStackFiles,tStackFile
  put the hilitedStackFiles of fld "stackfiles" into tStackFiles
  repeat for each line tStackFile in tStackFiles
    if the hilite of me then
      set the cRevStandaloneSettings["substackFolder"] of stack tStackFile to fld "substackFolder"
    else
      set the cRevStandaloneSettings["substackFolder"] of stack tStackFile to ""
    end if
    revSetEdit the short name of stack tStackFile
  end repeat
  set the enabled of fld "substackFolder" to the hilite of me
end mouseUp
