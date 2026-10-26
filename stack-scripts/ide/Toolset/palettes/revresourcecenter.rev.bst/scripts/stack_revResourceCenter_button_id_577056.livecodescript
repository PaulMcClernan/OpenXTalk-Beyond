script "stack_revResourceCenter_button_id_577056"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Linktextrollovereffect" (id 80250) > group "mainContent" (id 80257) > group (id 584230) > group "Example" (id 577002) > button "Underline Links" (id 577056)
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
