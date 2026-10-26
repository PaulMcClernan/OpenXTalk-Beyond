script "stack_revResourceCenter_graphic_id_579795"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Dragdropabackgroundcolorontoanobject" (id 80305) > group "mainContent" (id 80325) > group (id 579796) > group "Example" (id 579783) > graphic "Ball" (id 579795)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on dragEnter
  set the acceptDrop to true
end dragEnter

on dragDrop
  set the backgroundColor of the target to the dragData["text"]
  set the label of the target to the backgroundColor of the target && "ball"
end dragDrop
