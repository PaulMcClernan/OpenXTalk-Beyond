script "stack_revGettingStartedScripts_button_id_1151"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Find out the current platform and system version Example" (id 1150) > button "Is OS X?" (id 1151)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  get isOSX()
  if it then put "is" into myAnswer else put "is not" into myAnswer
  answer "Revolution" && myAnswer && "running on an OS X system." \
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
