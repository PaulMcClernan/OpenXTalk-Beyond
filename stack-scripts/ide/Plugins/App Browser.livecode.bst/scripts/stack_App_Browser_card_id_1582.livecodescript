script "stack_App_Browser_card_id_1582"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Blank" (id 1582)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
  if not (there is a field "select a card") then 
    exit preOpencard
  end if
  if the platform is "MacOS" then 
    set the textFont of field "select a card" to empty
  else 
    set the textFont of field "select a card" to "Helvetica"
  end if
  set the textSize of field "select a card" to 18
end preOpenCard
