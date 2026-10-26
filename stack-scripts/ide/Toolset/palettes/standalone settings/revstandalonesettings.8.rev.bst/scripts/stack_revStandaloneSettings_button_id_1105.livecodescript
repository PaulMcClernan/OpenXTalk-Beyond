script "stack_revStandaloneSettings_button_id_1105"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "OS X" (id 1015) > group "OSX" (id 1221) > button "Choose..." (id 1105)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# OK-2007-07-09 : Bug 4592
on mouseUp
  local tIconFile
  put utilityChooseIconFile("Mac OS X") into tIconFile
  if tIconFile is empty then
    exit mouseUp
  end if
  
  local tRelativeIconFile
  put utilityMakePathRelative(tIconFile, utilityTargetStackPath()) into tRelativeIconfile
  
  put tRelativeIconFile into field "iconFile"
  
  send "OSXpropertyChanged" && the id of field "iconFile" to the owner of field "iconFile"
end mouseUp




