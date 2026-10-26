script "stack_revResourceCenter_button_id_579851"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Placingafontlistintoamenu" (id 100330) > group "mainContent" (id 100342) > group (id 579852) > group "Example" (id 577033) > button "Update Font Menu" (id 579851)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  createFontMenu
end mouseUp

on createFontMenu
  get the fontNames -- list of installed fonts
  sort lines of it
  put it into button "Font"
end createFontMenu
