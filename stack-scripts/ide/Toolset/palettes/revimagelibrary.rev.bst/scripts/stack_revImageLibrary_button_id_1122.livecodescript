script "stack_revImageLibrary_button_id_1122"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002) > group "Buttons" (id 1165) > button "Import Selected" (id 1122)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put the name of  this stack into tLibStackName
  put "revLib" & the label of btn "library chooser" into tStackName
  put (the selObj) into tObjectsList
  put false into tImage
  repeat for each line l in tObjectsList
    if word 1 of l is "image" then
      put true into tImage
      put l & cr after tImagesList
    end if
  end repeat
  if not tImage then
    answer error "There are no images in the selection." with "Cancel" as sheet
    exit mouseUp
  end if
  delete last char of tImagesList
  lock messages
  set the defaultStack to the topStack
  repeat for each line l in tImagesList
    copy l to stack tStackName
    put the ID of last image of stack tStackName into tNewID
    put the id of l into tCurrentId
  end repeat
  compact stack tStackName
  save stack tStackName
  unlock messages
  set the defaultStack to "revImageLibrary"
  send "preOpenCard" to this cd of stack tLibStackName
end mouseUp
