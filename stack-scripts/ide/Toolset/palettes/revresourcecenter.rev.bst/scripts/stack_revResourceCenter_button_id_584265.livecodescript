script "stack_revResourceCenter_button_id_584265"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Findoutthecurrentplatformandsystemversion" (id 109160) > group "mainContent" (id 109172) > group (id 109171) > group "Example" (id 584264) > button "Is OS X?" (id 584265)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   get isOSX()
   local myAnswer
  if it then put "is" into myAnswer else put "is not" into myAnswer
  answer "LiveCode" && myAnswer && "running on an OS X system." \
  & return & tab & "Platform:" && the platform \
  & return & tab & "System version:" && the systemVersion
end mouseUp

function isOSX
  set the itemDelimiter to "."
  -- system versions are of the form "x.y.z"
  if the platform is "MacOS" \
      and item 1 of the systemVersion >= 10 \
      then return true
  else return false
end isOSX
