script "stack_revResourceCenter_button_id_579748"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "SwitchingBetweenStyledTextAndHTMLSource" (id 113788) > group "mainContent" (id 113802) > group "switchingtextstyles" (id 113797) > group "Example" (id 579745) > button "Switch" (id 579748)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the label of me is "Switch to HTML" then
    set the label of me to "Switch to Text"
    set the displayedFormat of field "Display" to "HTML"
  else
    set the label of me to "Switch to HTML"
    set the displayedFormat of field "Display" to "styled"
  end if
end mouseUp
