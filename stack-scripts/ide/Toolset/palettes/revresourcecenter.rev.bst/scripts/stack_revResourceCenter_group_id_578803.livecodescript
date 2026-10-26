script "stack_revResourceCenter_group_id_578803"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "InsertingSomeTextBeforeEachLineinaField" (id 100240) > group "mainContent" (id 100260) > group (id 578809) > group "Example" (id 578803)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put empty into field "Prefix"
  put empty into field "List"
  select text of field "Prefix"
end preOpenBackground
