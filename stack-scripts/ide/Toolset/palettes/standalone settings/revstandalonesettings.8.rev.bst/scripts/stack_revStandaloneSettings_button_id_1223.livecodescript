script "stack_revStandaloneSettings_button_id_1223"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Advanced Options" (id 2036) > group "selectedStack" (id 1261) > button "encrypt" (id 1223)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tStacks,tStack
  set the enabled of fld "encrypt" to the enabled of me
  put the hilitedStacks of field "stacks" into tStacks
  repeat for each line tStack in tStacks
    if the hilite of me then
      set the cRevStandaloneSettings["password"] of stack tStack to fld "encrypt"
    else
      set the cRevStandaloneSettings["password"] of stack tStack to ""
    end if
    revSetEdit the mainstack of stack tStack
  end repeat
end mouseUp
