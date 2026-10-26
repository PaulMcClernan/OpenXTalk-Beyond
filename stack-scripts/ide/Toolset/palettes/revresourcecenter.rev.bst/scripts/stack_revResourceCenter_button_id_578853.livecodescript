script "stack_revResourceCenter_button_id_578853"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Replacingatextstyleinafield" (id 109249) > group "mainContent" (id 109265) > group (id 584231) > group "Example" (id 577011) > button "Change underline to italic" (id 578853)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  underlineToItalic "Example Text"
  put the htmlText of field "Example Text" into field "Example HTML"
end mouseDown
 
on underlineToItalic theFieldName
  put the htmlText of field theFieldName into myHTML
  replace "<u>" with "<i>" in myHTML
  replace "</u>" with "</i>" in myHTML
  set the htmlText of field theFieldName to myHTML
end underlineToItalic
