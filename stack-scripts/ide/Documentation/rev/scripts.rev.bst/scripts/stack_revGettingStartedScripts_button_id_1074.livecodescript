script "stack_revGettingStartedScripts_button_id_1074"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Replacing a text style in a field Example" (id 1070) > button "Reset" (id 1074)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the htmlText of field "Example Text" to the savedHTMLText of field "Example Text"
  put the savedHTMLText of field "Example Text" into field "Example HTML"
end mouseUp
