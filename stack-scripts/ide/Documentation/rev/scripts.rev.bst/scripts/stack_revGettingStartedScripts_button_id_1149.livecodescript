script "stack_revGettingStartedScripts_button_id_1149"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Searching for an open window by title Example" (id 1148) > button "Find the stack labeled..." (id 1149)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  ask "Please enter a window title:"
  if it is empty then exit mouseUp
  put it into theLabel
  get titledWindowIsOpen(theLabel)
  if it is true then
    answer info "There is a window whose title (label) is" && theLabel & "."
  else
    beep
    answer info "There is no window whose title (label) is" && theLabel & "."
  end if
end mouseUp

function titledWindowIsOpen theTitle
  -- get the list of open stack names:
  put the openStacks into openStacksList
  repeat for each line thisStack in openStacksList
    -- check whether the title we want matches the label
    -- of any open stack:
    if the label of stack thisStack is theTitle then return true
  end repeat
  -- if we reach this point, the function hasn't returned yet,
  -- so the title wasn't found to belong to any open stack
  return false
end titledWindowIsOpen
