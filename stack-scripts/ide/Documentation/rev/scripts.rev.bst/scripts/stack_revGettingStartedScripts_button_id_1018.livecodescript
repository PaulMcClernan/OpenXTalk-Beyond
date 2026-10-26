script "stack_revGettingStartedScripts_button_id_1018"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Responding to a choice in a Window menu Example" (id 1015) > group "Menubar" (id 1017) > button "Window" (id 1018)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick -- goes in the menu button script
  -- This handler assumes the button has a custom property
  -- named "stackNamesList" that contains the names of
  -- the stacks listed in the menu
  put line (the menuHistory of me) \
     of the currentStacksList of me into chosenStackName
  go stack chosenStackName
  if the result is not empty then beep -- couldn't find stack
end menuPick 
