script "stack_revResourceCenter_button_id_579720"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "RemovingBoldTextStylesFromAField" (id 113724) > group "mainContent" (id 113740) > group (id 584245) > group "Example" (id 577013) > button "Remove Bold" (id 579720)
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
