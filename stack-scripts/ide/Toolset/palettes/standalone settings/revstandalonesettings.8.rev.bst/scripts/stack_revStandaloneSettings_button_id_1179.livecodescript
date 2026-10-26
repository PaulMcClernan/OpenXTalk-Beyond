script "stack_revStandaloneSettings_button_id_1179"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Bug Reports" (id 1017) > button "errorDialog" (id 1179)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the enabled of group "errorDialog" to the hilite of me
  -- OK-2007-09-26 : Bug 5436
  set the visible of button "BugsChecked" of group "checks" to the hilite of me
  set the cRevStandaloneSettings["errorDialog"] of stack the cRevTargetStack of this stack to the hilite of me
  revSetEdit
end mouseUp
