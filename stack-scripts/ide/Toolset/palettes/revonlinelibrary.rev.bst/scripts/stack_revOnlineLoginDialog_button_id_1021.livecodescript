script "stack_revOnlineLoginDialog_button_id_1021"
-- Stack file: ide/Toolset/palettes/revonlinelibrary.rev
-- Object: stack "revOnlineLibrary" > substack "revOnlineLoginDialog" > card (id 1002) > button "remember email" (id 1021)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me then
      set the enabled of button "remember password" of this card to true
   else
      set the enabled of button "remember password" of this card to false
      set the hilite of button "remember password" of this card to false
   end if
end mouseUp
