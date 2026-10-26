script "stack_revReplicate_button_id_1016"
-- Stack file: ide/Toolset/palettes/replicate.oxtstack
-- Object: stack "revReplicate" > card (id 1002) > button "offsetLockButton" (id 1016)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  if the iconState of me is unlocked then
    set the iconState of me to locked
    set the hilite of me to false
    set the toolTip of me to "Click to allow horizontal and vertical offsets to be changed independently"
  else
    set the iconState of me to unlocked
    set the hilite of me to true
    set the toolTip of me to "Click to keep the current ratio between horizontal and vertical offsets"
  end if
end mouseDown
