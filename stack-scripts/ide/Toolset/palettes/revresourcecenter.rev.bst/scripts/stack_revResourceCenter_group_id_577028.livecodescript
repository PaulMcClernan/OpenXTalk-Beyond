script "stack_revResourceCenter_group_id_577028"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "FindingLinesThatAreNotCommonToTwoContainers" (id 113667) > group "mainContent" (id 113683) > group (id 579836) > group "Example" (id 577028)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the initialText of field "List 1" into field "List 1"
  put the initialText of field "List 2" into field "List 2"
end preOpenBackground
