script "stack_revSearch_field_id_1248"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > field "Search Term" (id 1248)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on rawkeyDown
  send "revEnabler" to me in 10 milliseconds
  pass rawkeyDown 
end rawkeyDown

on deleteKey
  send "revEnabler" to me in 10 milliseconds
  pass deleteKey
end deleteKey

on backSpaceKey
  send "revEnabler" to me in 10 milliseconds
  pass backSpaceKey
end backSpaceKey

on cutKey
  send "revEnabler" to me in 10 milliseconds
  pass cutKey
end cutKey

on commandKeyDown
  send "revEnabler" to me in 50 milliseconds
  pass commandKeyDown
end commandKeyDown

on closeField
  send "revEnabler" to me in 10 milliseconds
end closeField

on revEnabler
  if the text of fld "Search Term" of cd 1 of stack "revSearch" is empty then disable btn "Search" of cd 1 of stack "revSearch"
  else enable btn "Search" of cd 1 of stack "revSearch"
end revEnabler
