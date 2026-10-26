script "stack_Book_Library"
-- Stack file: ide/Resources/Start Center/samples/sample_2/BookLibrary.livecode
-- Object: stack "Book Library"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sDatabaseID

on preOpenStack
   local tDatabaseFile
   #check specialFolderPath("documents") is not empty
   if specialFolderPath("documents") is not empty then      
   ## Connect to the SQLite database using the database file path
      put specialFolderPath("documents") & "/bookLibrary.sqlite" into tDatabaseFile
   else
      put specialFolderPath("temporary") & "/bookLibrary.sqlite" into tDatabaseFile
   end if
   
   if there is not a file tDatabaseFile then
      ## If the file does not exist it will be automatically created
      local tTableSQL
      
      ## Add a books table
      put revOpenDatabase("sqlite",tDatabaseFile) into sDatabaseID
      put "CREATE TABLE books(BookID INTEGER PRIMARY KEY AUTOINCREMENT, Title varchar(255),Author varchar(255),Status varchar(50),Comments varchar(500))" into tTableSQL
      revExecuteSQL sDatabaseID,tTableSQL
      
      ## Add some inital entries
      put "INSERT into books(Title,Author,Status) VALUES ('The Lord of the Rings','JRR Tolkien','On Shelf')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement
      put the result
      
      put "INSERT into books(Title,Author,Status) VALUES ('Pride and Prejudice','Jane Austen','On Shelf')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement
      
      put "INSERT into books(Title,Author,Status) VALUES ('His Dark Materials','Philip Pullman','On Shelf')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement
   else
      ## The database exists so simply connect to it
      put revOpenDatabase("sqlite",tDatabaseFile) into sDatabaseID
   end if
end preOpenStack

## Add a book to the database
command bookAdd pTitle, pAuthor, pStatus, pComments
   local tSQLStatement
   
   ## Construct the SQL statement and execute it on the database
   put "INSERT into books(Title,Author,Status,Comments) VALUES (" & quote & pTitle & quote & comma & quote & pAuthor & quote & comma & quote & pStatus & quote & comma & quote & pComments & quote & ")" into tSQLStatement
   revExecuteSQL sDatabaseID,tSQLStatement
   
   ## Give some feedback to the user
   if the result is an integer then
      answer "Book successfully added."
   else
      answer "Sorry, there was a problem adding that book."
   end if
end bookAdd

## Update a book in the database
command bookUpdate pBookID, pTitle, pAuthor, pStatus, pComments
   local tSQLStatement
   
   ## Construct the SQL statement and execute it on the database
   put "UPDATE books SET status='" & pStatus & "', title='" & pTitle & "',author='" & pAuthor & "',comments='" & pComments &"' WHERE BookID = '" & pBookID & "'" into tSQLStatement
   revExecuteSQL sDatabaseID,tSQLStatement
   
   ## Give some feedback to the user
   if the result is an integer then
      answer "Book successfully updated."
   else
      answer "Sorry, there was a problem updating that book."
   end if
end bookUpdate
   
   ## Delete a book from the database
command bookDelete pBookID
   local tSQLStatement
   
   ## Construct the SQL statement and execute it on the database
   put "DELETE from books WHERE BookID = '" & pBookID & "'" into tSQLStatement
   revExecuteSQL sDatabaseID,tSQLStatement
   
   ## Give some feedback to the user
   if the result is an integer then
      answer "Book successfully deleted."
   else
      answer "Sorry, there was a problem deleting that book."
   end if
end bookDelete

## Retrieve a list of books from the database and return it
function booksListAll
   local tSQLStatement, tList
   
   ## Construct the SQL statement and query the database
   put "SELECT Title,Author,Status,Comments, BookID from books" into tSQLStatement
   put revDataFromQuery(tab,return,sDatabaseID,tSQLStatement) into tList
   return tList
end booksListAll

## Retrieve a list of books where the Title or Author matches a search term
function booksSearch pSearchTerm
   local tSQLStatement, tList
   
   ## Construct the SQL statement and query the database
   put "SELECT Title,Author,Status,Comments,BookID from books WHERE title LIKE '%" & pSearchTerm & "%' OR author LIKE '%" & pSearchTerm & "%'" into tSQLStatement
   put revDataFromQuery(tab,return,sDatabaseID,tSQLStatement) into tList
   return tList
end booksSearch

on resizeStack
   send "layoutCard" to card "intro"
   send "layoutCard" to card "book data"
end resizeStack
