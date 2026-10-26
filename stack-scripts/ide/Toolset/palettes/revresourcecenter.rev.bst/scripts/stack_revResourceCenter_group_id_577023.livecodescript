script "stack_revResourceCenter_group_id_577023"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "TranslatingacolornametoanRGBnumerictriplet" (id 80452) > group "mainContent" (id 80463) > group (id 579808) > group "Example" (id 577023)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the colorNames into button "Color Name"
  set the label of button "Color Name" to "Black"
  put "The color" && quote & "Black" & quote && "is" && quote & "0,0,0" & quote & "." \
      into field "Color Result"
end preOpenBackground
