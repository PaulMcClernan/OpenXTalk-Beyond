script "stack_revOnline_group_id_3420214"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "edit stack" (id 3420214)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command resize
   set the loc field "edit content" of me to the loc of me
   set the topright of field "cancel" of me to the topright of me
   set the topright of button "cancel" of me to (the left of field "cancel" of me + 10, the top of me)
   set the topright of field "save" of me to (the left of button "cancel" of me + 10, the top of me)
   set the topright of button "save" of me to (the left of field "save" of me + 10, the top of me)
   set the topright of field "no" of me to the topright of me
   set the topright of button "no" of me to (the left of field "no" of me + 10, the top of me)
   set the topright of field "yes" of me to (the left of button "no" of me + 10, the top of me)
   set the topright of button "yes" of me to (the left of field "yes" of me + 10, the top of me)
   
   set the topleft of button "delete" of me to the topleft of me
   set the topleft of field "delete" of me to (the right of button "delete" of me - 10, the top of me)
   set the topleft of  button "update" of me to (the right of field "delete" of me - 10, the top of me)
   set the topleft of field "update" of me to (the right of button "update" of me - 10, the top of me)
   set the width of field "confirm" of me to the formattedwidth of field "confirm" of me + 10
   set the topright of field "confirm" of me to (the left of button "yes" of me + 15, the top of me)
end resize

command hideAll
   show field "edit content" of me
   hide field "cancel" of me
   hide button "cancel" of me
   hide field "save" of me
   hide button "save" of me
   hide field "yes" of me
   hide button "yes" of me
   hide field "no" of me
   hide button "no" of me
   hide field "update" of me
   hide button "update" of me
   hide field "delete" of me
   hide button "delete" of me   
   hide field "confirm" of me
end hideAll

command showEditControls pType
   hide field "edit content" of me
   show field "cancel" of me
   show button "cancel" of me
   show field "save" of me
   show button "save" of me
   show field "delete" of me
   show button "delete" of me
   show field "update" of me
   show button "update" of me
end showEditControls 

command showDeleteControls
   hide field "edit content" of me
   show field "confirm" of me
   show field "yes" of me
   show button "yes" of me
   show field "no" of me
   show button "no" of me
end showDeleteControls

command cancelContentChanges
   discardChanges
end cancelContentChanges

command saveContentChanges
   setStackDetails
end saveContentChanges

command showCancelControl
   hideAll
   hide field "edit content" of me
   show field "cancel" of me
   show button "cancel" of me
end showCancelControl

command showSaveCancelControls
   hideAll
   hide field "edit content" of me
   show field "cancel" of me
   show button "cancel" of me
   show field "save" of me
   show button "save" of me
end showSaveCancelControls



