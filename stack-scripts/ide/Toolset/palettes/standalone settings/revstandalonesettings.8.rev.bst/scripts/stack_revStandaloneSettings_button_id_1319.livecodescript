script "stack_revStandaloneSettings_button_id_1319"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > group "profiles" (id 1215) > group "include profiles" (id 1220) > button "all" (id 1319)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  disable field "include profiles"
  set the cRevStandaloneSettings["includeProfiles"] of stack the cRevTargetStack of this stack to "*"
  revSetEdit
  revGetProfileList
end mouseUp
