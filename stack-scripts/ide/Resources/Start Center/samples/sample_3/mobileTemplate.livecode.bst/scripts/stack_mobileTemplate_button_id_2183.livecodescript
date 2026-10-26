script "stack_mobileTemplate_button_id_2183"
-- Stack file: ide/Resources/Start Center/samples/sample_3/mobileTemplate.livecode
-- Object: stack "mobileTemplate" > card "template" (id 1868) > button "Reset" (id 2183)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   lock screen
   set the navigationItems of group "nav" of me to empty
   preOpenStack
   openCard
   unlock screen
end mouseUp
