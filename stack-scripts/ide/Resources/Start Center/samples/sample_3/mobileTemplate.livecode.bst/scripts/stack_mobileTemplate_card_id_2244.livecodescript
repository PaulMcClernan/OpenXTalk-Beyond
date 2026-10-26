script "stack_mobileTemplate_card_id_2244"
-- Stack file: ide/Resources/Start Center/samples/sample_3/mobileTemplate.livecode
-- Object: stack "mobileTemplate" > card "booking" (id 2244)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   set the theme of this stack to "red"
   set the headerTitle of this stack to "New Card"
   set the headerButtonBackVisible of this stack to false
   set the headerButtonAddVisible of this stack to false
   set the headerButtonUploadVisible of this stack to false
   set the headerButtonDeleteVisible of this stack to false
  set the navigationSelectedItem of this stack to the cNavID of me
end preOpenCard

on resizeStack
   lock screen
   
   set the width of button "ben" to the width of this stack
   set the left of button "ben" to 0
   
   unlock screen
   
   pass resizeStack
end resizeStack
