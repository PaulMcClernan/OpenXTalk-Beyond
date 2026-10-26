script "stack_revNewMenu_card_id_1002"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > substack "revNewMenu" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
  global gREVShowStacks
  lock screen
  lock messages
  set the loc of this stack to the loc of stack "revMenuManager"
  
  local tMenubarNumber
  put the cREVMenubarNumber of stack "revMenuManager" into tMenubarNumber
  add 1 to tMenubarNumber
  set the cREVMenubarNumber of stack "revMenuManager" to tMenubarNumber
  put "Menubar" && tMenubarNumber into fld "Name"
  put "File" & cr & "Edit" & cr & "Help" into fld "Menus"
  
  local tFilterStacksList
  put empty into tFilterStacksList
  put revFilterStacksList(the openStacks) into tFilterStacksList
  
  local tFirstSelectedStack
  put the cREVFirstSelectedStack of stack "revMenuManager" into tFirstSelectedStack
  if tFirstSelectedStack is not empty and tFirstSelectedStack is among the lines of the openStacks then
    set the label of btn "Open Stacks" to tFirstSelectedStack
    local tEnable
    put true into tEnable
  else
    switch
    case gREVShowStacks
      --operate on revolution stacks
      set the label of btn "Open Stacks" to the short name of the topStack
      put true into tEnable
      break
    case tFilterStacksList is empty
      --no non-revolution stacks open
      set the label of btn "Open stacks" to space
      disable fld "Menus"
      disable btn "OK"
      send "revAnswerNoStacks" to me in 10 milliseconds
      break
    default
      --operate on topmost non-revolution stack
      put tFilterStacksList into btn "Open Stacks"
      local tTopStack
      put the short name of the topStack into tTopStack
      if tTopStack is among the lines of tFilterStacksList
      then set the label of btn "Open Stacks" to tTopStack
      else set the label of btn "Open Stacks" to line 1 of tFilterStacksList
      put true into tEnable
      break
    end switch
  end if
  if the cMBMoveObjects of stack "revPreferences" is empty then
    local tStack
    put the label of btn "Open Stacks" into tStack
    if there is a stack tStack then
      if the num of controls in stack tStack = 0 then
        unhilite btn "Move Objects"
      else
        hilite btn "Move Objects"
      end if
    else
      hilite btn "Move Objects"
    end if
  else set the hilite of btn "Move Objects" to the cMBMoveObjects of stack "revPreferences"
  if tEnable then 
    enable btn "OK"
    enable fld "Menus"
  end if
  set the cREVResult of this stack to empty
  select the text of fld "Name"
  unlock messages
  unlock screen
end preOpenStack

on revAnswerNoStacks
   answer information "No suitable stacks to create a new menu in.  Either open the stack you want to edit or turn on the" && quote & "UI stacks in lists" & quote && "preference."
end revAnswerNoStacks

# OK-2007-09-19 : Bug 5410, Called when the user clicks the Ok button or presses enter
command closeAccept
  lock screen
  local tMenuBar
  put the text of field "Name" of me into tMenubar
  
  local tDefaultStack
  put the label of button "Open Stacks" into tDefaultStack
  if there is a group tMenubar of stack tDefaultStack then
    beep
    answer warning "A group with this name already exists in stack" && quote & tDefaultStack & quote & ".  Please specify a different name." 
    select the text of field "Name" of me
    return "group already exists"
  end if
  
  set the cREVMenuButtonCardID of stack "revMenuManager" to empty
  set the cREVResult of this stack to "OK"
  set the cREVMenusToBuild of this stack to the text of field "Menus" of me
  
  set the cREVFirstSelectedStack of stack "revMenuManager" to tDefaultStack
  set the cREVDefaultStack of stack "revMenuManager" to tDefaultStack
  set the cREVMenubar of stack "revMenuManager" to tMenubar
  set the cMBMoveObjects of stack "revPreferences" to the hilite of button "Move Objects" of me
  close this stack
  unlock screen
  
  return empty
end closeAccept

command closeReject
  # OK-2007-09-24 : Bug 5409. As in this case a menu has not been created, we decrement the menu counter property
  set the cREVMenubarNumber of stack "revMenuManager" to the cREVMenubarNumber of stack "revMenuManager" - 1
  close this stack
end closeReject


