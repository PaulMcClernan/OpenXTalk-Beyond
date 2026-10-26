script "stack_revStandaloneProgress"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > substack "revStandaloneProgress"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
  
end preOpenStack

on openStack
  
end openStack

on openCard
  send "startLoading" to group "Loader" of card 1 of me
end openCard

on preOpenCard
  
end preOpenCard

on closeStack
  send "stopLoading" to group "Loader" of card 1 of me
end closeStack


