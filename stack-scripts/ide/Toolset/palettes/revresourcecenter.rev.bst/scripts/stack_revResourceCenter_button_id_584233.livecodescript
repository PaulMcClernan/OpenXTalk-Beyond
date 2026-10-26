script "stack_revResourceCenter_button_id_584233"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "ListingAllTheUniqueWordsInAPieceOfText" (id 113707) > group "mainContent" (id 113722) > group (id 584238) > group "Example" (id 584232) > button "Choose..." (id 584233)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer file "Please choose a text file:"
  if it is empty then exit mouseUp -- no file chosen
  put the itemDelimiter into savedDelimiter
  set the itemDelimiter to "/"
  put "File:" && last item of it into field "Filename"
  set the itemDelimiter to savedDelimiter
  put uniqueWordsOf(URL ("file:" & it)) into field "Unique Words"
end mouseUp

function uniqueWordsOf theString
  repeat for each word thisWord in theString
    add 1 to wordsList[thisWord]
  end repeat
  return the keys of wordsList
end uniqueWordsOf
