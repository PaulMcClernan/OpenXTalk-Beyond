script "stack_revResourceCenter_group_id_579784"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Dragdropabackgroundcolorontoanobject" (id 80305) > group "mainContent" (id 80325) > group (id 579796) > group "Example" (id 579783) > group "Colors" (id 579784)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
  set the dragData["text"] to the short name of the target
  set the borderWidth of the target to 3
end mouseDown

on dragEnd
  set the borderWidth of the target to 1
end dragEnd
