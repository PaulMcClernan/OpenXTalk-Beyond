script "stack_revResourceCenter_field_id_579746"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "SwitchingBetweenStyledTextAndHTMLSource" (id 113788) > group "mainContent" (id 113802) > group "switchingtextstyles" (id 113797) > group "Example" (id 579745) > field "Display" (id 579746)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

setProp displayedFormat theType
  -- accepts "HTML" (default) or "styled"
  if theType is "HTML" then
    set the text of the target to the htmlText of the target
  else
    set the htmlText of the target to the text of the target
  end if
end displayedFormat
