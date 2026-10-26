script "stack_revObjectProperties_button_id_1013"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > substack "revObjectProperties" > card (id 1002) > group "Object Properties to Search In:" (id 1029) > button "Other Properties" (id 1013)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilite of me then
    enable btn "all other object properties"
    enable btn "specific property"
    disable btn "specific property selector"
    set the hilite of btn "all other object properties" to true
    set the hilite of btn "specific property" to false
  else
    disable btn "specific property selector"
    disable btn "all other object properties"
    disable btn "specific property"
  end if
end mouseUp
