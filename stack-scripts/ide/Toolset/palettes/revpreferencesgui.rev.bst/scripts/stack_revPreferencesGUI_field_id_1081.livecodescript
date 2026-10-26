script "stack_revPreferencesGUI_field_id_1081"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > field "tooltip delay" (id 1081)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local toolTipDelayLastValue -- stores previous contents in case of error

on closeField
  if the text of me is not an integer then
    beep
    put toolTipDelayLastValue into me
  else if the text of me < zero then
    beep
    put toolTipDelayLastValue into me
  end if
  set the toolTipDelay to me
  set the cREVToolTipDelay of stack "revPreferences" to me
end closeField

on openField
  put the text of me into toolTipDelayLastValue
end openField

on keyDown theKey
  if theKey is in "0123456789" then pass keyDown else beep
end keyDown
