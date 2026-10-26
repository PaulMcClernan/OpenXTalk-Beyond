script "stack_revGettingStartedScripts_group_id_1122"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Drag drop a background color onto an object Example" (id 1121) > group "Colors" (id 1122)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  set the dragData["text"] to the short name of the target
  set the borderWidth of the target to 3
end mouseDown

on dragEnd
  set the borderWidth of the target to 1
end dragEnd
