script "stack_com.livecode.pi.customprops_button_id_1016"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.customprops.livecode
-- Object: stack "com.livecode.pi.customprops" > card (id 1002) > group "template" (id 1004) > group "Set buttons" (id 1012) > group "buttons" (id 1018) > button "Remove" (id 1016)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tSet
   put the label of button "customPropertySet" into tSet
   if tSet is "customKeys" then
      answer warning "Really delete all properties inside the customKey set?" with "Cancel" or "Delete"
      if it is "Cancel" then
         exit mouseUp
      end if
   end if
   
   dispatch "propSetDeleted" with tSet
end mouseUp
