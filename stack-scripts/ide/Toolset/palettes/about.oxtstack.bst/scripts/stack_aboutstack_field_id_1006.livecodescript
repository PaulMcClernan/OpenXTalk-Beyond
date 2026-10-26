script "stack_aboutstack_field_id_1006"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack" > card "id 1002" (id 1002) > group "sharedbits" (id 1012) > field "buildfield" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put word 1 to 2 of me into myCopy
   set the clipboardData["text"] to myCopy
   put myCopy & " (copied to clipboard)" into me
end mousedown
