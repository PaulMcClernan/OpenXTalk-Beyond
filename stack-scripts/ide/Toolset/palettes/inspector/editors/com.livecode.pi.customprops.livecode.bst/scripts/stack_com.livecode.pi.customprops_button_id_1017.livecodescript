script "stack_com.livecode.pi.customprops_button_id_1017"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.customprops.livecode
-- Object: stack "com.livecode.pi.customprops" > card (id 1002) > group "template" (id 1004) > group "Set buttons" (id 1012) > group "buttons" (id 1018) > button "rename" (id 1017)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tLine
   put the label of btn "customPropertySet" into tLine
   if tLine is "customKeys" then
      beep
      exit mouseUp
   end if
   ask question "Please enter a new name:" with tLine as sheet
   if it is empty then exit mouseUp
   if it is among the lines of the propertyNames then
      answer error "A custom property set name cannot be a property name." as sheet
      exit mouseUp
   end if
   
   local tName
   put revValidSetName(it) into tName
   dispatch "propSetRenamed" with tLine, tName
end mouseUp
