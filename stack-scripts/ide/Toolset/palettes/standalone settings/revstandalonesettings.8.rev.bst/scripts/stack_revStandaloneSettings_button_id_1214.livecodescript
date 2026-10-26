script "stack_revStandaloneSettings_button_id_1214"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > group "profiles" (id 1215) > button "set objects" (id 1214)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pWhich
  set the cRevStandaloneSettings["setToProfile"] of stack the cRevTargetStack of this stack to pWhich
  revSetEdit
end menuPick
