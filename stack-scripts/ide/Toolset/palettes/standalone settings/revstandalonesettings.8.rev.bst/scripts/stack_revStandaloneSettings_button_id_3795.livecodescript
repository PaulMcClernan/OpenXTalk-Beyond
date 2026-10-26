script "stack_revStandaloneSettings_button_id_3795"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Emscripten" (id 3757) > group "emscriptenSettings" (id 3820) > group "platforms" (id 3810) > button "Emscripten" (id 3795)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cRevStandaloneSettings[the short name of me] of stack the cRevTargetStack of this stack to the hilite of me
   buildForEnabled "emscripten"
   revSetEdit
end mouseUp
