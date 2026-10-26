script "stack_revMenuDialog_card_id_1002"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > substack "revMenuDialog" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
  global gREVShowStacks
  lock screen
  lock messages
  put empty into field "Menus"
  
  local tFilterStacksList
  put empty into tFilterStacksList
  put revFilterStacksList(the openStacks) into tFilterStacksList
  set the cREVMenuIDs of this stack to empty
   
  local tFirstSelectedStack
  put the cREVFirstSelectedStack of stack "revMenuManager" into tFirstSelectedStack
  if tFirstSelectedStack is not empty and tFirstSelectedStack is among the lines of the openStacks then
    set the label of button "Open Stacks" to tFirstSelectedStack
    set the cREVSelectedStack of this stack to tFirstSelectedStack
    local tEnable
    put true into tEnable
  else
    switch
    case gREVShowStacks
      --operate on revolution stacks
      set the label of button "Open Stacks" to the short name of the topStack
      set the cREVSelectedStack of this stack to the short name of the topStack
      put true into tEnable
      break
    case tFilterStacksList is empty
      --no non-revolution stacks open
      --disable
      set the label of button "Open Stacks" to space
      set the cREVSelectedStack of this stack to empty
      disable field "Menus"
      put false into tEnable
      break
    default
      --operate on topmost non-revolution stack
      local tTopStack
      put the short name of the topStack into tTopStack
      
      local tStack
      if tTopStack is among the lines of tFilterStacksList then
        put tTopStack into tStack
      else 
        put line 1 of tFilterStacksList into tStack
      end if
      set the label of button "Open Stacks" to tStack
      set the cREVSelectedStack of this stack to tStack
      put true into tEnable
      break
    end switch
  end if
   
  set the cREVResult of this stack to empty
  if tEnable then
    revRefreshMenuField
  else
    disable button "OK"
    send "revAnswerNoStacks" to me in 10 milliseconds
  end if
  unlock messages
  unlock screen
end preOpenStack

on revRefreshMenuField
  --refresh menu field
  --show all grps containing menu buttons and all menu buttons
  enable field "Menus"
  set the defaultStack to (the cREVSelectedStack of this stack)
  local tHCAddressing
  put the hcAddressing of this stack into tHCAddressing
  set the hcAddressing of this stack to false
  
  local tNumControls
  put the num of controls into tNumControls
  
  local tMenus
  put empty into tMenus
  repeat with i = 1 to tNumControls
    local tName
    put the name of control i into tName
    if word 1 of tName is "group" then
      local tNumButtons
      put the num of buttons of tName into tNumButtons
      
      if tNumButtons is empty then next repeat
      repeat with j = 1 to tNumButtons
        if the style of button j of tName is "menu" then
          put tName & cr after tMenus --group contains at least one menu button, add it to list
          local tMenuIDs
          put the id of control i & cr after tMenuIDs
          exit repeat
        end if
      end repeat
    else next repeat
  end repeat
 
   
  delete last char of tMenus
  delete last char of tMenuIDs
  set the hcAddressing of this stack to tHCAddressing
  set the defaultStack to "revMenuDialog"
  put tMenus into field "Menus"
  set the cREVMenuIDs of this stack to tMenuIDs
  disable button "OK"
  set the hilitedLine of field "Menus" to empty
end revRefreshMenuField

on revAnswerNoStacks
   answer information "No suitable stacks to create a new menu in.  Either open the stack you want to edit or turn on the" && quote & "UI stacks in lists" & quote && "preference."
end revAnswerNoStacks

# OK-2007-09-25 : Refactored from "OK" button script. Called when the user clicks ok or double clicks in the menus field
command closeAccept
  lock screen
  lock messages
  
  local tSelectedObject
  put the selectedObject into tSelectedObject
  
  local tSelectedText
  put the selectedText of field "Menus" into tSelectedText
  
  local tDefaultStack
  put the cREVSelectedStack of this stack into tDefaultStack
  if tSelectedText is not empty then
    set the cREVMenuObject of stack "revMenuManager" to "group"
    set the cREVMenuButtonCardID of stack "revMenuManager" to empty
    set the cREVMenuID of stack "revMenuManager" to line (the hilitedLine of field "Menus") of the cREVMenuIDs of this stack
    set the cREVResult of this stack to "OK"
     
    set the cREVFirstSelectedStack of stack "revMenuManager" to tDefaultStack
    set the cREVDefaultStack of stack "revMenuManager" to tDefaultStack
    set the defaultStack to tDefaultStack
    set the cREVMenubar of stack "revMenuManager" to the short name of tSelectedText
    set the defaultStack to "revMenuDialog"
  end if
  close this stack
  unlock messages
  unlock screen
end closeAccept

command closeReject
  close this stack
end closeReject



