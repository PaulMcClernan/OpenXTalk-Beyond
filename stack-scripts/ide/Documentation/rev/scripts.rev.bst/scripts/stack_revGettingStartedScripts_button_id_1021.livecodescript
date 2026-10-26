script "stack_revGettingStartedScripts_button_id_1021"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Link text roll over effect Example" (id 1019) > button "Underline Links" (id 1021)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilite of me then
    set the underlineLinks of this stack to true
    set the linkColor of this stack to "blue"
    set the linkVisitedColor of this stack to "blue"
  else
    set the underlineLinks of this stack to false
    set the linkColor of this stack to "black"
    set the linkVisitedColor of this stack to "black"
  end if
end mouseUp
