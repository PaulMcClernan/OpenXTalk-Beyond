script "stack_revGettingStartedScripts_group_id_1057"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Updating a menu with a list of open Windows Example" (id 1055) > group "Menubar" (id 1057)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown -- goes in the menubar group script
  if the short name of the target is "Window" then
    -- the user clicked the Window menu, not some other menu
   repeat for each line thisStack in the openStacks
      -- skip palettes and dialog boxes (unless Option or
      -- Alt key is pressed):
      if the mode of stack thisStack > 2 \
         and the optionKey is not down then next repeat
      -- List the stack names for later:
      put thisStack & return after stacksList
      -- List the stack by its title, if available:
      put the title of stack thisStack into thisStacktitle
      if the number of words in thisStacktitle <> zero then
        put thisStacktitle & return after windowsList
      else -- no title, so use the stack name instead:
        put thisStack & return after windowsList
      end if
    end repeat
    if windowsList is empty then -- no stack windows open
      put "(No windows open" into windowsList
    end if
    -- put the list into the menu:
    put windowsList into button "Window" of me
    -- set a custom property for later use:
    set the currentStacksList of the target to stacksList
  end if
end mouseDown 
