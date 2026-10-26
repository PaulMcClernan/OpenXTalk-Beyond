script "stack_Card_Navigator_button_id_1028"
-- Stack file: ide/Toolset/palettes/navigatorIDE.oxtstack
-- Object: stack "Card Navigator" > card (id 1002) > group "navbtns" (id 1016) > button "Delete Card" (id 1028)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put cd fld "stackName" into tStack
   try
      if the number of cards in stack tStack is 1 then 
         Answer "You cannot delete this card, because it's the only card in the stack '" & tStack & "'."
      else
         put the currentcard of stack tStack into tCardID
         put the last word of tCardID into tJustCardID 
         put the name of card ID tJustCardID of stack tStack into tJustCardName
         Answer "Are you sure you want to delete card:" & return &¬
         "Name: " & tJustCardName & return &¬
         "ID: " & tJustCardID & return &¬
         "Number: " & the number of card id tJustCardID of stack tStack & " of " & the number of cards of stack tStack & return &¬
         "Of stack: '" & tStack & "' ?" with "Delete" or "Cancel"
         if it is "Delete" then delete the card ID tJustCardID of stack tStack
      end if
   catch e
   end try
end mousedown

