script "stack_revDocsSupported_Platforms_Reference_field_id_1165"
-- Stack file: ide/Documentation/rev/Supported Platforms Referen.rev
-- Object: stack "revDocsSupported Platforms Reference" > card "Intro" (id 1002) > group "Platforms List" (id 1175) > field "Platforms List" (id 1165)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lastHilitedLine
local lockedDownNow

on mouseDown
  lock screen
  go card (the value of the clickLine)
  unlock screen with visual wipe right very fast
end mouseDown

on mouseMove
  put the mouseLine into currentLine
  if currentLine is empty then exit mouseMove -- no text under the mouse
  if lastHilitedLine is empty then put currentLine into lastHilitedLine
  if currentLine is not lastHilitedLine then
    do "set the textColor of" && lastHilitedLine && "to empty"
    put currentLine into lastHilitedLine
  end if
  do "set the textColor of" && currentLine && "to" && the contentsHiliteColor of me
end mouseMove

on mouseLeave
  if lockedDownNow then pass mouseLeave
  if lastHilitedLine is not empty then do "set the textColor of" && lastHilitedLine && "to empty"
end mouseLeave
