script "stack_revRotate_card_id_1002"
-- Stack file: ide/Toolset/palettes/revrotate.livecode
-- Object: stack "revRotate" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
  set the cRotateGraphic of this stack to empty
end preOpenStack
  
on enterKey
  click at the loc of btn "OK"
end enterKey

on returnKey
  enterKey
end returnKey

on enterInField
  enterKey
end enterInField

on returnInField
  enterKey
end returnInField
