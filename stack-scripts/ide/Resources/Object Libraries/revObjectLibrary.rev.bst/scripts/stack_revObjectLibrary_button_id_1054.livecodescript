script "stack_revObjectLibrary_button_id_1054"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "MacOS Style Stack Width Flipper" (id 1053) > button "Mac Stack Width Flipper" (id 1054)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilite of me then set the rect of this stack to the topLeft of this stack, the left of this stack + the cContractedStackWidth of me, the bottom of this stack
  else set the rect of this stack to the topLeft of this stack, the left of this stack + the cExpandedStackWidth of me, the bottom of this stack
end mouseUp

on mouseDoubleUp
  mouseUp
end mouseDoubleUp
