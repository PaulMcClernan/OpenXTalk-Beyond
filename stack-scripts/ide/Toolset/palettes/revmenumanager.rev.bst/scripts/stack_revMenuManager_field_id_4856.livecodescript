script "stack_revMenuManager_field_id_4856"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menubar" (id 3260) > field "Menubar" (id 4856)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lDontDoCloseField

on closeField
  global gREVActiveMenuButton
  lock screen
  put the text of me into tNewMenubarName
  --closeField called from returnInField
  if the cREVMenubar of this stack is tNewMenubarName or lDontDoCloseField then
    pass closeField
  end if
  put false into lDontDoCloseField
  put the cREVDefaultStack of this stack into tDefaultStack
  
  if tNewMenubarName is empty then
    --Check the Menu Bar Name hasn't been set to empty
    beep
    lock messages
    put true into lDontDoCloseField
    --Message don't lock when brining up answer dialog therefore
    --need to workaround closeField being sent twice
    answer error "You must enter a name."
    put false into lDontDoCloseField
    put the short name of bg id (the cREVMenuID of this stack) of stack tDefaultStack into me
    select char 1 to - 1 of me
    unlock messages
    pass closeField    
  end if
  
  if there is a bg tNewMenubarName of stack tDefaultStack then
    --Check that a Group of this name doesn't already exist
    beep
    lock messages
    put true into lDontDoCloseField
    --Message don't lock when brining up answer dialog therefore
    --need to workaround closeField being sent twice
    answer error "A group with this name already exists in stack" && quote & tDefaultStack & quote & ".  Please specify a different name."
    put false into lDontDoCloseField
    put the short name of bg id (the cREVMenuID of this stack) of stack tDefaultStack into me
    select char 1 to - 1 of me
    unlock messages
    pass closeField
  end if
  set the name of bg id (the cREVMenuID of this stack) of stack tDefaultStack to tNewMenubarName
  if the label of btn "MacOS Preview" is not empty
  then set the defaultMenubar to tNewMenubarName
  set the cREVMenubar of this stack to tNewMenubarName
  send "mouseUp" to fld "Menu Buttons"
  pass closeField
  unlock screen
end closeField

on returnInField
  lock screen
  closeField
  select the text of me
  unlock screen
end returnInField

on enterInField
  returnInField
end enterInField
