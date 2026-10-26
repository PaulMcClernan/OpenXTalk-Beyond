script "stack_revResourceCenter_group_id_577048"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Convertingarelativepathtoanabsolutepath" (id 102575) > group "mainContent" (id 102592) > group (id 579908) > group "Example" (id 577048)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Path"
  put the defaultFolder into field "Starting Folder"
end preOpenBackground
