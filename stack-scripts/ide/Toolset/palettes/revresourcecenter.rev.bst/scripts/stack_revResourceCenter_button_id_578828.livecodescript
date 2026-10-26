script "stack_revResourceCenter_button_id_578828"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Combinerandomtextstrings" (id 109204) > group "mainContent" (id 109225) > group (id 109220) > group "Example" (id 578821) > button "Generate Insult" (id 578828)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer shakespeareanInsult() with "Gahk!"
end mouseUp

function shakespeareanInsult
  return "Begone, thou" \
      && any word of the firstAdjectiveList of me \
      && any word of the secondAdjectiveList of me \
      && any word of the nounsList of me & "!"
end shakespeareanInsult
