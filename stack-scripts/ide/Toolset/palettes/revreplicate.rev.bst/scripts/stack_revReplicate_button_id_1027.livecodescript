script "stack_revReplicate_button_id_1027"
-- Stack file: ide/Toolset/palettes/revreplicate.rev
-- Object: stack "revReplicate" > card (id 1002) > button "scaleLockButton" (id 1027)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  if the iconState of me is unlocked then
    set the iconState of me to locked
    set the hilite of me to false
    set the toolTip of me to "Click to allow horizontal and vertical scale to be changed independently"
  else
    set the iconState of me to unlocked
    set the hilite of me to true
    set the toolTip of me to "Click to keep the current ratio between horizontal and vertical scale"
  end if
end mouseDown
