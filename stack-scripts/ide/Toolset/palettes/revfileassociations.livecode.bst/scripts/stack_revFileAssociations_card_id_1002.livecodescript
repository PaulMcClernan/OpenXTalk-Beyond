script "stack_revFileAssociations_card_id_1002"
-- Stack file: ide/Toolset/palettes/revfileassociations.livecode
-- Object: stack "revFileAssociations" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
  local tTopLeft
  put the topLeft of button "Show" into tTopLeft
  set the width of button "Show" to the formattedWidth of button "Show"
  set the topLeft of button "Show" to tTopLeft
  
  local tOldLoc
  if the platform is "macos" and the left of button "Yes" < the left of button "No" then
    put the loc of button "Yes" into tOldLoc
    set the loc of button "Yes" to the loc of button "No"
    set the loc of button "No" to tOldLoc
  else if the platform is "win32" and the left of button "No" < the left of button "Yes" then
    put the loc of button "No" into tOldLoc
    set the loc of button "No" to the loc of button "Yes"
    set the loc of button "Yes" to tOldLoc
 end if
 
 set the hilite of button "Show" to (the cDontShowFileAssociationsDialog of stack "revPreferences" is true)
end preOpenCard

on answerQuestion pAnswer
  if pAnswer is "Yes" then
    revInternal__InstallFileAssociations
  end if
  close this stack
end answerQuestion
