script "stack_com.livecode.pi.customprops_button_id_1015"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.customprops.livecode
-- Object: stack "com.livecode.pi.customprops" > card (id 1002) > group "template" (id 1004) > group "Set buttons" (id 1012) > group "buttons" (id 1018) > button "New" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   ask question "Enter a name for the new custom property set" as sheet
   if it is empty then exit mouseUp
   set the caseSensitive to true
   if it is among the lines of the propertyNames then
      answer error "A custom property set name cannot be a property name." as sheet
      exit mouseUp
   end if
   
   local tName
   put revValidSetName(it) into tName
   dispatch "propSetAdded" with tName
end mouseUp
