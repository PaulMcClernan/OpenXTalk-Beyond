script "stack_Magnify_card_id_104"
-- Stack file: ide/Toolset/palettes/revicons.rev
-- Object: stack "revIcons" > substack "Magnify" > card "Magnifier Card" (id 104)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeStack
  set the width of this stack to 256
  set the height of this stack to 256
end closeStack

on resizeStack
  set the rect of magnifier 1 to 0,0,the width of this stack,the height of this stack
end resizeStack
