script "stack_revGettingStartedScripts_button_id_1181"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Listing all the unique words in a piece of text Example" (id 1180) > button "Choose..." (id 1181)
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
