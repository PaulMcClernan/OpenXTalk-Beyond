script "stack_revStandaloneSettings_button_id_1496"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > button "Automatically build here" (id 1496)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cRevStandaloneSettings["automaticallyBuildInDefaultFolder"] of stack (the cRevTargetStack of this stack) to the hilite of me
   revIDESetEdited the cRevTargetStack of this stack
end mouseUp
