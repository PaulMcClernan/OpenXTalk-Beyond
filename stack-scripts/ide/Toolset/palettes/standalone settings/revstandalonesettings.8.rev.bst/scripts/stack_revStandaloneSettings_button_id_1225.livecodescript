script "stack_revStandaloneSettings_button_id_1225"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Advanced Options" (id 2036) > group "selectedStack" (id 1261) > button "destroyStack" (id 1225)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tStacks,tStack
  put the hilitedStacks of field "stacks" into tStacks
  repeat for each line tStack in tStacks
    set the cRevStandaloneSettings["destroyStack"] of stack tStack to the hilite of me
    revSetEdit the mainstack of stack tStack
  end repeat
  revSetEdit
end mouseUp
