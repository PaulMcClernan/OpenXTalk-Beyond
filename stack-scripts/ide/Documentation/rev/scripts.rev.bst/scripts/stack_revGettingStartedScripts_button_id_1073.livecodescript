script "stack_revGettingStartedScripts_button_id_1073"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Replacing a text style in a field Example" (id 1070) > button "Change underline to italic" (id 1073)
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
