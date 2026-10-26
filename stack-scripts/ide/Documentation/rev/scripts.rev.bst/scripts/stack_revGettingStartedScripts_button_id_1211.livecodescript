script "stack_revGettingStartedScripts_button_id_1211"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Removing bold text styles from a field Example" (id 1208) > button "Remove Bold" (id 1211)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  removeBold "Example Text"
  put the htmlText of field "Example Text" into field "Example HTML"
end mouseDown
  
on removeBold theFieldName
  put the htmlText of field theFieldName into myHTML
  replace "<b>" with empty in myHTML
  replace "</b>" with empty in myHTML
  set the htmlText of field theFieldName to myHTML
end removeBold
