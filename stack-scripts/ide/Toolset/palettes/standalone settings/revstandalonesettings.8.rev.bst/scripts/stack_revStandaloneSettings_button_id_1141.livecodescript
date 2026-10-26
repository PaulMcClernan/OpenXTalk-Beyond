script "stack_revStandaloneSettings_button_id_1141"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > group "Windows" (id 1169) > button "Choose...2" (id 1141)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# OK-2007-07-09 : Bug 4592, Rewrote this as part of bug fix
on mouseUp
  local tIconFile
  put utilityChooseIconFile("Windows") into tIconFile
  
  if tIconFile is empty then
    exit mouseUp
  end if
  
  local tRelativeIconFile
  put utilityMakePathRelative(tIconFile, utilityTargetStackPath()) into tRelativeIconFile
  
  put tRelativeIconFile into field "documenticonFile"
  
  send "WINpropertyChanged" && the id of field "documenticonFile" to the owner of field "documenticonFile"
end mouseUp
