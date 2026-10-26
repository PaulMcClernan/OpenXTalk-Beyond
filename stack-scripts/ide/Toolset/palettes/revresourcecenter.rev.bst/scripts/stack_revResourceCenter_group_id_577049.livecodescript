script "stack_revResourceCenter_group_id_577049"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "convertinganabsolutepathtoarelativepath" (id 104775) > group "mainContent" (id 104792) > group (id 584271) > group "Example" (id 577049)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Path"
  put the defaultFolder into field "Starting Folder"
end preOpenBackground
