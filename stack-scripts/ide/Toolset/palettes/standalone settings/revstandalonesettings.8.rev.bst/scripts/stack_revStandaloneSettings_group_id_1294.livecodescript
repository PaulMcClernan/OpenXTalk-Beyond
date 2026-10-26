script "stack_revStandaloneSettings_group_id_1294"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > group "inclusions" (id 1294)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp   
   set the cRevStandaloneSettings["inclusions"] of \
         stack the cRevTargetStack of this stack to \
         the hilitedButtonName of me
   
   revSetEdit
   send "preOpenCard" to this card
end mouseUp
