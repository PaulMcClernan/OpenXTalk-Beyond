script "stack_Bookshelf_field_id_1224"
-- Stack file: ide/Resources/Examples/Remastered/Bookshelf.oxtstack
-- Object: stack "Bookshelf" > card "Book Data" (id 1032) > field "Search Term" (id 1224)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField
   ## This message is sent when the retun key is pressed
   ## By handling it here we "trap" it meaning there cannot be multiple lines in the field
   ## Call searchBooks so the list is filtered when return is pressed
   searchBooks
end returnInField

on enterInField
   ## As with return but for enter
   searchBooks
end enterInField

-- (remaster) and as you type
on textChanged
   searchBooks
end textChanged

-- (remaster) The window goes from page to
-- page with the left and right arrow keys,
-- but not in a field being typed in. While
-- the search is empty, they go from page to
-- page here too
on arrowKey pKey
   if me is empty and (pKey is "left" or pKey is "right") then
      focus on nothing
   end if
   pass arrowKey
end arrowKey
