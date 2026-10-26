script "stack_revImageLibrary_button_id_1142"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Objects" (id 1150) > button "Delete" (id 1142)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put the cStackName of fld "objects list" into tStackName
  put the name of this stack into tLibStackName
  if tStackName is "revDefaultLibrary" then
    answer error "The standard library cannot be deleted." with "OK" as sheet
    exit mouseUp
  end if
  answer warning "Really delete library" && tStackName & "?  This cannot be undone."  with "Cancel" or "Delete" as sheet
  if it is "cancel" then exit mouseUp
  put the fileName of stack tStackName into tFilePath
  delete stack tStackName
  delete file tFilePath
  set the defaultStack to tLibStackName
  preOpenCard
end mouseUp
