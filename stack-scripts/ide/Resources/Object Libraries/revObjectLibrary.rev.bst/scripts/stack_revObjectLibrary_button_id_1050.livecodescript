script "stack_revObjectLibrary_button_id_1050"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "MacOS Style Stack Height Flipper" (id 1049) > button "Mac Stack Height Flipper" (id 1050)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilite of me then set the rect of this stack to the topLeft of this stack, the right of this stack, the top of this stack + the cContractedStackHeight of me 
  else set the rect of this stack to the topLeft of this stack, the right of this stack, the top of this stack + the cExpandedStackHeight of me
end mouseUp

on mouseDoubleUp
  mouseUp
end mouseDoubleUp
