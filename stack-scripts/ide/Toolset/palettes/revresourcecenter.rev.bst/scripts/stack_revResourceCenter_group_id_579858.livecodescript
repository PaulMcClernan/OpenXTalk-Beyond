script "stack_revResourceCenter_group_id_579858"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Respondingtoachoiceinawindowmenu" (id 100301) > group "mainContent" (id 100314) > group (id 584260) > group "Example" (id 577035) > group "Menubar" (id 579858)
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
      -- List the stack by its label, if available:
      put the label of stack thisStack into thisStackLabel
      if the number of words in thisStackLabel <> zero then
        put thisStackLabel & return after windowsList
      else -- no label, so use the stack name instead:
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
