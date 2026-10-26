script "stack_revResourceCenter_button_id_579721"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "RemovingBoldTextStylesFromAField" (id 113724) > group "mainContent" (id 113740) > group (id 584245) > group "Example" (id 577013) > button "Reset" (id 579721)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the htmlText of field "Example Text" to the savedHTMLText of field "Example Text"
  put the savedHTMLText of field "Example Text" into field "Example HTML"
end mouseUp
