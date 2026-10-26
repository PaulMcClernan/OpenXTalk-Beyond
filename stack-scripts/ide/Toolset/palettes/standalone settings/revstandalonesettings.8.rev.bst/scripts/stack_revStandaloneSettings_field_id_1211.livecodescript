script "stack_revStandaloneSettings_field_id_1211"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > group "profiles" (id 1215) > field "include profiles" (id 1211)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tList
  repeat for each item tItem in the hilitedLines of me
    put line tItem of me &cr after tList
  end repeat
  set the cRevStandaloneSettings["includeProfiles"] of stack the cRevTargetStack of this stack to tList
  revSetEdit
end mouseUp
