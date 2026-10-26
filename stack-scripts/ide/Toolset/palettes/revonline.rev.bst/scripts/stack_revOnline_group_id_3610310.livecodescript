script "stack_revOnline_group_id_3610310"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "edit controls" (id 3610310)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command initialize
   
end initialize

local sType
local sEnabled

setProp cType pType
   put pType into sType
end cType

setProp cEnabled pEnabled
   put pEnabled into sEnabled
   showEnabled
end cEnabled

command hideAll
   hide field "edit" of me
   hide button "save" of me
   hide field "save" of me
   hide button "cancel" of me
   hide field "cancel" of me
   hide field "update" of me
   hide button "update" of me
   hide field "delete" of me
   hide button "delete" of me
   hide field "confirm" of me
   hide field "yes" of me
   hide button "yes" of me
   hide field "no" of me
   hide button "no" of me
end hideAll

command resize
   set the loc of field "edit" of me to the loc of me
   
   set the topright of field "cancel" of me to the topright of me
   set the topright of button "cancel" of me to (the left of field "cancel" of me + 12, the top of me)
   set the topright of field "save" of me to (the left of button "cancel" of me + 5, the top of me)
   set the topright of button "save" of me to (the left of field "save" of me + 12, the top of me)
   
   
   set the topright of field "no" of me to the topright of me
   set the topright of button "no" of me to (the left of field "no" of me + 12, the top of me)
   set the topright of field "yes" of me to (the left of button "no" of me + 5, the top of me)
   set the topright of button "yes" of me to (the left of field "yes" of me + 12, the top of me)
   set the topright of field "confirm" of me to the topleft of button "yes" of me
   
   set the topleft of button "delete" of me to (the left of me + 12, the top of me)
   set the topleft of field "delete" of me to (the right of button "delete" of me - 12, the top of me)
   set the topleft of button "update" of me to (the right of field "delete" of me - 5, the top of me)
   set the topleft of field "update" of me to (the right of button "update" of me - 12, the top of me)
   
end resize

command showEnabled
   hideAll
   if sEnabled is true then
      if sType is "stack" then
         put "Edit stack" into field "edit" of me
      else if sType is "code snippet" then
         put "Edit code snippet" into field "edit" of me
      else if sType is "external" then
         put "Edit external" into field "edit" of me
      else if sType is "profile" then
         put "Edit profile" into field "edit" of me
      else
      end if
      show field "edit" of me
   end if
end showEnabled

command showEditControls
   hide field "edit" of me
   show button "save" of me
   show field "save" of me
   show button "cancel" of me
   show field "cancel" of me
   if sType is not "profile" then
      show field "update" of me
      show button "update" of me
      show field "delete" of me
      show button "delete" of me
      send "editDetails" to group "stack" of group "viewing pane" of stack "revonline"
   else
     send "editProfile" to group "user" of group "viewing pane" of stack "revonline"
   end if
end showEditControls

command cancelChanges
   hideAll
   if sType is "profile" then
      send "discardChanges" to group "user" of group "viewing pane" of stack "revonline"
   else
      send "discardChanges" to group "stack" of group "viewing pane" of stack "revonline"
   end if
   
end cancelChanges

command saveChanges
   hideAll
   if sType is "profile" then
      send "setUserData" to group "user" of group "viewing pane" of stack "revonline"
   else
      send "setStackDetails" to group "stack" of group "viewing pane" of stack "revonline"
      if the result is "false" then
         showNewStackControls
      end if
   end if
end saveChanges

command showDeleteConfirmation
   hideAll
   show field "confirm" of me
   show field "yes" of me
   show button "yes" of me
   show field "no" of me
   show button "no" of me
end showDeleteConfirmation

command deleteStack
   send "deleteStack" to group "stack" of group "viewing pane" of stack "revonline"
end deleteStack

command updateStack
   hideAll
   local tUpdate = "update"
   send "showContentChooser tUpdate" to group "stack" of group "viewing pane" of stack "revonline"
end updateStack

command showNewStackControls
   hideAll
   show field "save" of me
   show button "save" of me
   show field "cancel" of me
   show button "cancel" of me
end showNewStackControls

