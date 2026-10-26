script "stack_revResourceCenter_button_id_579859"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Respondingtoachoiceinawindowmenu" (id 100301) > group "mainContent" (id 100314) > group (id 584260) > group "Example" (id 577035) > group "Menubar" (id 579858) > button "Window" (id 579859)
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
