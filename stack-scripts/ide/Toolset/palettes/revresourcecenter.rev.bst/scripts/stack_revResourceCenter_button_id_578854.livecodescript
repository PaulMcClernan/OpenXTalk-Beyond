script "stack_revResourceCenter_button_id_578854"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Replacingatextstyleinafield" (id 109249) > group "mainContent" (id 109265) > group (id 584231) > group "Example" (id 577011) > button "Reset" (id 578854)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the htmlText of field "Example Text" to the savedHTMLText of field "Example Text"
  put the savedHTMLText of field "Example Text" into field "Example HTML"
end mouseUp
