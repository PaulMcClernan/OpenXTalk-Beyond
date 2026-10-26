script "stack_revStandaloneSettings_group_id_1178"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "UNIX" (id 1035) > group "UNIX" (id 1178)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  repeat with X=1 to the number of btns of me
    set the cRevStandaloneSettings["UNIX",the short name of btn X of me] of stack the cRevTargetStack of this stack to the hilite of btn X of me
  end repeat
  revSetEdit
end mouseUp
