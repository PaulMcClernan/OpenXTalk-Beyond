script "stack_revStandaloneSettings_button_id_1318"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > group "profiles" (id 1215) > button "set" (id 1318)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  disable field "include profiles"
  disable group "include profiles"
  enable btn "set objects"
  set the cRevStandaloneSettings["includeProfiles"] of stack the cRevTargetStack of this stack to ""
  set the cRevStandaloneSettings["setToProfile"] of stack the cRevTargetStack of this stack to the label of btn "set objects"
  revSetEdit
  revGetProfileList
end mouseUp
