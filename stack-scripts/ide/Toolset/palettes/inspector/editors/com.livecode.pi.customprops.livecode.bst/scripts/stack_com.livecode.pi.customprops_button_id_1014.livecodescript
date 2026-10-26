script "stack_com.livecode.pi.customprops_button_id_1014"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.customprops.livecode
-- Object: stack "com.livecode.pi.customprops" > card (id 1002) > group "template" (id 1004) > group "Set buttons" (id 1012) > button "customPropertySet" (id 1014)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pWhich
   dispatch "propSetSelected" with pWhich
end menuPick
