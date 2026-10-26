script "stack_revStandaloneSettings_field_id_1224"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Advanced Options" (id 2036) > group "selectedStack" (id 1261) > field "encrypt" (id 1224)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keyUp 
  if not (the hilite of btn "encrypt") then
    set the hilite of btn "encrypt" to true
    send "mouseUp" to btn "encrypt"
  end if
end keyUp

on keyDown
  if not the enabled of btn "encrypt" then exit keyDown
  else pass keyDown
end keyDown

on closeField
  local tStacks,tStack
  put the hilitedStacks of field "stacks" into tStacks
  repeat for each line tStack in tStacks
    set the cRevStandaloneSettings["password"] of stack tStack to me
    revSetEdit the mainstack of stack tStack
  end repeat
end closeField
