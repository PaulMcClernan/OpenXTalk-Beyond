script "stack_aboutstack_button_id_1004"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack" > card "id 1002" (id 1002) > group "sharedbits" (id 1012) > button "Close" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   --send preopenstack to this stack
   set the destroyStack of this stack to true
   close this stack
end mouseup
