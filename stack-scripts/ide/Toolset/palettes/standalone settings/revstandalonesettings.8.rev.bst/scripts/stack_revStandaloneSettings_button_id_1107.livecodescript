script "stack_revStandaloneSettings_button_id_1107"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "OS X" (id 1015) > group "OSX" (id 1221) > group "choose" (id 1284) > button "Choose..." (id 1107)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the platform is "Win32" 
  then put "PLIST Files" & cr & "*.plist" into tFilter
  else put empty into tFilter
  answer file "Select a file:" with filter tFilter
  if it is empty then exit mouseUp
  put it into tFile
  set the itemDel to "/"
  put item 1 to -2 of the fileName of stack (the cRevTargetStack of this stack)&"/" into tMainStackPath
  put the number of chars of tMainStackPath into tChars
  if char 1 to tChars of tFile = tMainStackPath then delete char 1 to tChars of tFile
  put tFile into fld "plist"
  send closeField to fld "plist"
end mouseUp
