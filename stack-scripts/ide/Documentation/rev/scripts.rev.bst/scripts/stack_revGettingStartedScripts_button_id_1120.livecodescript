script "stack_revGettingStartedScripts_button_id_1120"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Placing a font list into a menu Example" (id 1117) > button "Update Font Menu" (id 1120)
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
