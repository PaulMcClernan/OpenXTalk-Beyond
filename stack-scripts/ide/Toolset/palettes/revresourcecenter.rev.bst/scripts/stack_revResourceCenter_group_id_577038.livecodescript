script "stack_revResourceCenter_group_id_577038"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Speakinganalertmessage" (id 100210) > group "mainContent" (id 100222) > group (id 579871) > group "Example" (id 577038)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the defaultAlert of field "Speech" into field "Speech"
end preOpenBackground
