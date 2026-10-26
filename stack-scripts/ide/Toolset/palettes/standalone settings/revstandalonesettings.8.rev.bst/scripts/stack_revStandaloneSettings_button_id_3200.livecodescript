script "stack_revStandaloneSettings_button_id_3200"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > group "Windows" (id 1169) > button "usePixelScaling" (id 3200)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cRevStandaloneSettings["Windows,usePixelScaling"] of stack the cRevTargetStack of this stack to the hilite of me
   revSetEdit
end mouseUp
