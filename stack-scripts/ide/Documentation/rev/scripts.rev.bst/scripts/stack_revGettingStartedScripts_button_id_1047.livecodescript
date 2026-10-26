script "stack_revGettingStartedScripts_button_id_1047"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Combine random text strings Example" (id 1040) > button "Generate Insult" (id 1047)
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
