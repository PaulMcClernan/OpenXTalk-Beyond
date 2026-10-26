script "stack_Book_Library_card_id_1002"
-- Stack file: ide/Resources/Start Center/samples/sample_2/BookLibrary.livecode
-- Object: stack "Book Library" > card "book data" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   layoutCard
   
   ## Clear the search and entry fields
   put empty into field "Search Term"
   clearFields
   
   ## Populate the list of books
   listBooks
end preOpenCard

command clearFields
   ## Clear the entry fields
   put empty into field "Title"
   put empty into field "Author"
   put empty into field "Comments"
   put empty into field "BookID"
   
   ## Set the Option menu to the default
   set the label of button "Status" to "On Shelf"
end clearFields

command editFields
   ## Make the entry fields editable
   set the lockText of field "Title" to false
   set the lockText of  field "Author" to false
   set the lockText of field "Comments" to false
   set the enabled of button "Status" to true
   
   set the showBorder of field "Title" to true
   set the showBorder of field "Author" to true
end editFields

command lockFields
   ## Make the fields read only
   set the lockText of field "Title" to true
   set the lockText of  field "Author" to true
   set the lockText of field "Comments" to true
   set the enabled of button "Status" to false
   
   set the showBorder of field "Title" to false
   set the showBorder of field "Author" to false
end lockFields

command listBooks
   local tList 
   put booksListAll() into tList
   put tList into field "List"
end listBooks

command searchBooks
   local tSearchTerm, tList
   
   put field "Search Term" into tSearchTerm
   put booksSearch(tSearchTerm) into tList
   put tList into field "List"
end searchBooks

command showBookDetails
   local tLineNumber, tBookDetails
   
   ## Get the hilited line number of the list
   ## Get the text of that line
   put the hilitedLine of field "List" into tLineNumber
   put line tLineNumber of field "List" into tBookDetails 
   
   ## Set the item delimiter to tab
   ## This allows us to refer to each tab separated item
   set the itemDelimiter to tab
   put item 1 of tBookDetails into field "Title"
   put item 2 of tBookDetails into field "Author"
   set the label of button "Status" to item 3 of tBookDetails
   put item 4 of tBookDetails into field "Comments"
   
   ## The BookID is an invisible field, used to identify the book
   put item 5 of tBookDetails into field "BookID"
   
   ## Make the fields non editbale
   lockFields
   
   ## Disable the Cancel and Save buttons
   set the disabled of button "Cancel" to true
   set the disabled of button "Save" to true
end showBookDetails

command saveBook
   local tTitle, tAuthor, tStatus, tComments, tBookID
   local tPath
   
   ## Retrieve the user input
   put field "Title" into tTitle
   put field "Author" into tAuthor
   put the label of button "Status" into tStatus
   put field "Comments" into tComments
   put field "BookID" into tBookID
   
   ## Check for return chracters in comments 
   ## Not allowed as our data is line separated
   ## Replace with a space instead
   replace return with space in tComments
   
   if tBookID is empty then
      ## This is a new book
      ## Add the book to the database
      bookAdd tTitle, tAuthor, tStatus, tComments
   else
      ## This is an update
      ## Only the status can be updated
      bookUpdate tBookID, tTitle, tAuthor, tStatus, tComments
   end if
   
   ## Update the list of books
   ## Clear the entry fields
   lock screen
   listBooks   
   clearFields
   unlock screen
end saveBook

## Prepare the details pane for a new book entry
command newBook
   lock screen
   clearFields
   
   ## Make the fields editbale
   editFields
   
   ## Enable the Cancel and Save buttons
   set the enabled of button "Cancel" to true
   set the enabled of button "Save" to true
   
   focus on field "title"
   unlock screen
end newBook

## Prepare the details pane to edit a book entry
command editBook
   lock screen
   showBookDetails
   
   ## Make the fields editbale
   editFields
   
   ## Enable the Cancel and Save buttons
   set the enabled of button "Cancel" to true
   set the enabled of button "Save" to true
   
   focus on field "title"
   unlock screen
end editBook

command deleteBook
   local tLineNumber, tBookID
   
   ## Get the hilited line number of the list
   ## Get the title of that book
   set the itemDel to tab
   put the hilitedLine of field "List" into tLineNumber
   put item 5 of line tLineNumber of field "List" into tBookID 
   
   ## Check the user wants to delete the book
   answer "Are you sure you want to delete this book?" with "OK" or "Cancel"
   if it is "OK" then
      
      ## Delete the selected book
      bookDelete tBookID
      
      ## Refresh the list
      clearFields
      listBooks
   end if
end deleteBook

command layoutCard
   ## This handler lays out all controls based on the size of the stack
   local tLeftPaneWidth, tRightPaneWidth
   put round(the width of this stack/3) into tLeftPaneWidth
   put round(the width of this stack/3)*2 into tRightPaneWidth
   
   set the height of graphic "verticalDiv" of me to the height of this stack
   set the topLeft of graphic "verticalDiv" of me to tLeftPaneWidth,0
   set the width of field "search term" of me to tLeftPaneWidth - 97
   set the topLeft of field "search term" of me to 5,5
   set the topLeft of button "search" of me to the right of field "search term" of me + 5, 5
   
   set the width of field "list titles" of me to tLeftPaneWidth - 20
   set the left of field "list titles" of me to 10
   set the width of field "list" of me to tLeftPaneWidth - 20
   set the height of field "list" of me to the height of this stack - 120
   set the topLeft of field "list" of me to 10, the bottom of field "list titles" of me + 10
   set the topLeft of button "Add Book" of me to 10, the bottom of field "list" of me + 10
   set the topLeft of button "Edit Book" of me to the right of button "Add Book" of me + 5, the bottom of field "list" of me + 10
   set the topRight of button "delete book" of me to the right of field "list" of me, the bottom of field "list" of me + 10
   
   set the left of field "title label" of me to tLeftPaneWidth
   set the left of field "author label" of me to tLeftPaneWidth
   set the left of field "status label" of me to tLeftPaneWidth
   set the left of field "comments label" of me to tLeftPaneWidth
   
   set the left of field "title" of me to the right of field "title label" of me 
   set the left of field "author" of me to the right of field "author label" of me
   set the left of button "status" of me to the right of field "status label" of me
   
   set the width of field "comments" of me to tRightPaneWidth - 120
   set the height of field "comments" of me to the height of this stack - 150
   set the topLeft of field "comments" of me to the topRight of field "comments label" of me
   set the topRight of button "save" of me to the right of field "comments" of me,the bottom of field "comments" of me + 10
   set the topRight of button "cancel" of me to the topLeft of button "save" of me
end layoutCard
