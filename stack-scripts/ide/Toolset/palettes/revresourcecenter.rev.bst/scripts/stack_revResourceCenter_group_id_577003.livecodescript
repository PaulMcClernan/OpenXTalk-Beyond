script "stack_revResourceCenter_group_id_577003"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Showorhideascrollbarautomaticallyastextisenteredinafield" (id 80261) > group "mainContent" (id 80271) > group (id 577915) > group "Example" (id 577003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  put the originalText of field "Example" into field "Example"
end preOpenBackground

on openBackGround
  select after text of field "Example"
end openBackGround
