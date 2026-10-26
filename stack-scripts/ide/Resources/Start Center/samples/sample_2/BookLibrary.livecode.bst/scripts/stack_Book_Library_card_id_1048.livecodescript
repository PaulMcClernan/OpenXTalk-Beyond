script "stack_Book_Library_card_id_1048"
-- Stack file: ide/Resources/Start Center/samples/sample_2/BookLibrary.livecode
-- Object: stack "Book Library" > card "intro" (id 1048)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on layoutCard
   set the width of field "intro" of me to the width of this stack - 20
   set the height of field "intro" of me to the height of this stack  - 80
   set the topLeft of field "intro" of me to 10,10
   set the bottomRight of button "Go" of me to the width of this stack - 10, the height of this stack - 10
end layoutCard
