script "stack_revResourceCenter_button_id_579872"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Centeringawindowonthescreen" (id 80273) > group "mainContent" (id 80282) > group (id 584263) > group "Example" (id 577039) > button "Center Me!" (id 579872)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  centerMe
end mouseUp

on centerMe
  set the loc of this stack to the screenLoc
end centerMe
