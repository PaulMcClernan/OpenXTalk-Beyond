script "stack_revGettingStartedScripts_button_id_1104"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Converting an absolute path to a relative path Example" (id 1101) > button "Browse..." (id 1104)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer folder "Please choose a starting point for the relative path:"
  if it is not empty then put it into field "Starting Folder"
end mouseUp
