script "stack_revGettingStartedScripts_button_id_1253"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Switching between styled text and HTML source Example" (id 1250) > button "Switch" (id 1253)
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
