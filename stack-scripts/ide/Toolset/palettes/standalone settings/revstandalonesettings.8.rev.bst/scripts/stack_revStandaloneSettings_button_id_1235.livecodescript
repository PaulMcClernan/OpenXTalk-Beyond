script "stack_revStandaloneSettings_button_id_1235"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Basic Options" (id 2037) > button "Remove Stack File" (id 1235)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tRemove,tLines,tFiles,tItem
  if the hilitedLines of fld "stackfiles" is not empty then
    put the hilitedLines of fld "stackfiles" into tLines
    put the cStackPaths of fld "stackfiles" into tFiles
    repeat for each item tItem in tLines
      if tItem = 1 then
        answer error "The standalone mainstack can not be removed from the application."
      else
        put line tItem of tFiles & cr after tRemove
      end if
    end repeat
    delete char -1 of tRemove
    revRemoveStackFiles tRemove
  end if
end mouseUp
