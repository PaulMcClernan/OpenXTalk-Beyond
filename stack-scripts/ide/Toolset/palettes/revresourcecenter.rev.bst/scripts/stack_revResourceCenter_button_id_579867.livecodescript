script "stack_revResourceCenter_button_id_579867"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Searchingforanopenwindowbytitle" (id 98013) > group "mainContent" (id 98023) > group (id 584262) > group "Example" (id 577037) > button "Find the stack labeled..." (id 579867)
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
