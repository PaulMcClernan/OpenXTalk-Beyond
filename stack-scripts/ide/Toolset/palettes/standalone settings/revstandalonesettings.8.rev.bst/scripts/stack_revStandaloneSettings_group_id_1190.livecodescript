script "stack_revStandaloneSettings_group_id_1190"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Bug Reports" (id 1017) > group "errorDialog" (id 1190)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  set the cRevStandaloneSettings["ErrorDialog,"&the short name of the target] of stack the cRevTargetStack of this stack to the text of the target
  revSetEdit
  pass closeField
end closeField

on returnInField
  set the cRevStandaloneSettings["ErrorDialog,"&the short name of the target] of stack the cRevTargetStack of this stack to the text of the target
  revSetEdit
  pass returnInField
end returnInField

on tabKey
  set the cRevStandaloneSettings["ErrorDialog,"&the short name of the target] of stack the cRevTargetStack of this stack to the text of the target
  revSetEdit
  pass tabKey
end tabKey

on mouseUp
  if word 1 of the target = "button" then
    set the cRevStandaloneSettings["ErrorDialog,"&the short name of the target] of stack the cRevTargetStack of this stack to the hilite of the target
    revSetEdit
  end if
  pass mouseUp
end mouseUp
