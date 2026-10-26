script "stack_revGettingStartedScripts_graphic_id_1133"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Drag drop a background color onto an object Example" (id 1121) > graphic "Ball" (id 1133)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on dragEnter
  set the acceptDrop to true
end dragEnter

on dragDrop
  set the backgroundColor of the target to the dragData["text"]
  set the label of the target to the backgroundColor of the target && "ball"
end dragDrop
