script "stack_revOnline_card_id_1002"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   if char 1 of the version < 7 then
      set the textColor of field "login status" of group "menubar" to "white"
      set the textColor of field "email" of group "menubar" to "white"
      set the textColor of field "controls" of group "menubar" to "white"
   else
      set the textColor of field "login status" of group "menubar" to empty
      set the textColor of field "controls" of group "menubar" to empty
      set the textColor of field "email" of group "menubar" to empty
   end if
end preOpenCard
