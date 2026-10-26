script "stack_Bookshelf_button_id_1263"
-- Stack file: ide/Resources/Examples/Remastered/Bookshelf.oxtstack
-- Object: stack "Bookshelf" > card "Book Data" (id 1032) > button "Status" (id 1263)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- (remaster) The sample's Status was an
-- option menu, which shows the status
-- chosen by itself. This one is a pulldown
-- menu, drawn as the window draws its other
-- controls, and it shows the status chosen
-- here. Its menu is its text: On Shelf, and
-- On Loan.
on menuPick pItem
   set the label of me to pItem
end menuPick
