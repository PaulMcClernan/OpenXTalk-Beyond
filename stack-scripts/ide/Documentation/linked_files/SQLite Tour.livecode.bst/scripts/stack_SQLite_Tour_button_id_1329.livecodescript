script "stack_SQLite_Tour_button_id_1329"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Introduction" (id 1002) > button "Reset Fields" (id 1329)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tCards
   put the number of cards into tCards
   repeat with i = 1 to tCards
      set the lockText of fld "TheText" of cd i to not the lockText of fld "TheText" of cd i  --toggle true/false
      set the traversalOn of fld "TheText" of cd i to not the traversalOn of fld "TheText" of cd i
      --set the textSize of fld "TheText" of cd i to empty  --use stack textSize of 15
      set the fixedLineHeight of fld "TheText" of cd i to false
   end repeat
   answer "The lockText of all fields is now" && the lockText of fld "TheText" &"." with "OK" titled "Reset Fields"
end mouseUp
