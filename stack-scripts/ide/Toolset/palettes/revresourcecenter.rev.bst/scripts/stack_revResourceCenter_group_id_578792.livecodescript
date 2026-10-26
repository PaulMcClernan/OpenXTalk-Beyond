script "stack_revResourceCenter_group_id_578792"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Insertinglinebreakstohardwraptext" (id 80438) > group "mainContent" (id 80450) > group (id 578797) > group "Example" (id 578792)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the originalText of field "Example Text" into field "Example Text"
  put "30" into field "Line Length"
end preOpenBackground
