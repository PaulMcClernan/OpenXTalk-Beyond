script "stack_revImageLibrary_button_id_1118"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002) > button "Delete..." (id 1118)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put the label of btn "library chooser" into tStackName
  put the name of this stack into tLibStackName
  if tStackName is among the items of "Standard Images,MetaCard Compatible Icons,Cursors,-" or word 1 to 2 of tStackName is "This Stack"  then
    answer error "You can't delete set" && tStackName & "." with "Cancel" as sheet
    exit mouseUp
  end if
  answer warning "Are you sure you want to delete the image library" && quote & tStackName & quote & "?  This operation cannot be undone." with "Delete" or "Cancel" as sheet
  if it is "cancel" then exit mouseUp
  put "revLib" before tStackName
  hide stack tStackName
  toplevel tStackName
  put the effective fileName of stack tStackName into tFileName
  delete stack tStackName
  if there is a file tFileName then
    delete file tFileName
  end if
  send "preOpenCard" to this cd of stack tLibStackName
end mouseUp

on mouseEnter
  
end mouseEnter
