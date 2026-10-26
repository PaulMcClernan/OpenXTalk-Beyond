script "stack_Bookshelf"
-- Stack file: ide/Resources/Examples/Remastered/Bookshelf.oxtstack
-- Object: stack "Bookshelf"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--Bookshelf: LiveCode Ltd's Book Library, the second sample of the Start Center, remastered for OXT-Beyond in 2026
--Book Library: LiveCode Ltd, 2014. It came with LiveCode Community, under the GNU General Public License, version 3

--These are the database handlers: preOpenStack opens the library, and makes it the first time, and
--the others add, update, delete and find books in it. The window's handlers are in the script of the
--card "Book Data", and call these. What the remaster added or changed is marked (remaster).

local sDatabaseID
-- (remaster) Why the library could not be opened, if it could not
local sDatabaseProblem

on preOpenStack
   local tDatabaseFile
   local tSQLStatement -- (remaster) declared, for strict compilation
   put empty into sDatabaseProblem
   -- (remaster) Without the database library, revDB, the stack opens all
   -- the same, and the list says why it is empty
   if not databaseLoaded() then
      put "The database library, revDB, is not loaded here." into sDatabaseProblem
      exit preOpenStack
   end if
   #check specialFolderPath("documents") is not empty
   -- (remaster) and that the folder is there: a computer may have none
   if specialFolderPath("documents") is not empty and there is a folder specialFolderPath("documents") then
      ## Connect to the SQLite database using the database file path
      -- (remaster) The library is the file bookLibrary.sqlite in your
      -- documents folder, where you can write (this stack's own folder may
      -- be the application's, where you cannot). In a browser, the web
      -- engine keeps the documents folder for the page
      put specialFolderPath("documents") & "/bookLibrary.sqlite" into tDatabaseFile
   else
      put specialFolderPath("temporary") & "/bookLibrary.sqlite" into tDatabaseFile
   end if

   if there is not a file tDatabaseFile then
      ## If the file does not exist it will be automatically created
      local tTableSQL

      ## Add a books table
      put revOpenDatabase("sqlite",tDatabaseFile) into sDatabaseID
      put "CREATE TABLE books(BookID INTEGER PRIMARY KEY AUTOINCREMENT, Title VARCHAR(255),Author VARCHAR(255),Status VARCHAR(50),Comments VARCHAR(500))" into tTableSQL
      revExecuteSQL sDatabaseID,tTableSQL

      ## Add some inital entries
      put "INSERT INTO books(Title,Author,Status) VALUES ('The Lord of the Rings','JRR Tolkien','On Shelf')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement
      -- put the result -- (remaster) a line left from testing: it put the result in the Message Box

      put "INSERT INTO books(Title,Author,Status) VALUES ('Pride and Prejudice','Jane Austen','On Shelf')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement

      put "INSERT INTO books(Title,Author,Status) VALUES ('His Dark Materials','Philip Pullman','On Shelf')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement
   else
      ## The database exists so simply connect to it
      put revOpenDatabase("sqlite",tDatabaseFile) into sDatabaseID
   end if

   -- (remaster) A database that did not open says why, in the list
   if sDatabaseID is not an integer then
      put sDatabaseID into sDatabaseProblem
      put empty into sDatabaseID
   end if
end preOpenStack

-- (remaster) True where the database library, revDB, is loaded: the IDE
-- loads it, and the web engine has it built in. Without it, its commands
-- would stop the stack with an error
function databaseLoaded
   local tError
   try
      get revOpenDatabases()
   catch tError
      return false
   end try
   return true
end databaseLoaded

-- (remaster) Why the library could not be opened, or empty if it was
function databaseProblem
   return sDatabaseProblem
end databaseProblem

## Add a book to the database
command bookAdd pTitle, pAuthor, pStatus, pComments
   local tSQLStatement
   if sDatabaseID is empty then exit bookAdd -- (remaster) no database: see preOpenStack

   ## Construct the SQL statement and execute it on the database
   -- (remaster) The original put the words themselves into the SQL, each
   -- between double quotes:
   --    put "INSERT into books(Title,Author,Status,Comments) VALUES (" & quote & pTitle & quote & comma & quote & pAuthor & quote & comma & quote & pStatus & quote & comma & quote & pComments & quote & ")" into tSQLStatement
   -- so a double quote in a title broke the SQL, and SQLite took a title
   -- that is a column's name, such as Title, for that column. :1 to :4
   -- stand for the variables named after the SQL, whose words go to
   -- SQLite as they are
   put "INSERT INTO books(Title,Author,Status,Comments) VALUES (:1, :2, :3, :4)" into tSQLStatement
   revExecuteSQL sDatabaseID,tSQLStatement, "pTitle", "pAuthor", "pStatus", "pComments"

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
   if sDatabaseID is empty then exit bookUpdate -- (remaster) no database: see preOpenStack

   ## Construct the SQL statement and execute it on the database
   -- (remaster) with :1 to :5, as bookAdd does. The original's
   --    put "UPDATE books SET status='" & pStatus & "', title='" & pTitle & "',author='" & pAuthor & "',comments='" & pComments &"' WHERE BookID = '" & pBookID & "'" into tSQLStatement
   -- broke on a word with an apostrophe in it, such as Charlotte's Web
   put "UPDATE books SET status=:1, title=:2, author=:3, comments=:4 WHERE BookID = :5" into tSQLStatement
   revExecuteSQL sDatabaseID,tSQLStatement, "pStatus", "pTitle", "pAuthor", "pComments", "pBookID"

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
   if sDatabaseID is empty then exit bookDelete -- (remaster) no database: see preOpenStack

   ## Construct the SQL statement and execute it on the database
   -- (remaster) with :1, as bookAdd does. The original's
   --    put "DELETE from books WHERE BookID = '" & pBookID & "'" into tSQLStatement
   -- put the number itself into the SQL
   put "DELETE FROM books WHERE BookID = :1" into tSQLStatement
   revExecuteSQL sDatabaseID,tSQLStatement, "pBookID"

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
   if sDatabaseID is empty then return empty -- (remaster) no database: see preOpenStack

   ## Construct the SQL statement and query the database
   put "SELECT Title,Author,Status,Comments, BookID FROM books" into tSQLStatement
   put revDataFromQuery(tab,return,sDatabaseID,tSQLStatement) into tList
   return tList
end booksListAll

## Retrieve a list of books where the Title or Author matches a search term
function booksSearch pSearchTerm
   local tSQLStatement, tList
   local tPattern -- (remaster) what LIKE looks for: % is any letters
   if sDatabaseID is empty then return empty -- (remaster) no database: see preOpenStack

   ## Construct the SQL statement and query the database
   -- (remaster) with :1, as bookAdd does. The original's
   --    put "SELECT Title,Author,Status,Comments,BookID from books WHERE title LIKE '%" & pSearchTerm & "%' OR author LIKE '%" & pSearchTerm & "%'" into tSQLStatement
   -- broke on a word with an apostrophe in it
   put "%" & pSearchTerm & "%" into tPattern
   put "SELECT Title,Author,Status,Comments,BookID FROM books WHERE title LIKE :1 OR author LIKE :1" into tSQLStatement
   put revDataFromQuery(tab,return,sDatabaseID,tSQLStatement,"tPattern") into tList
   return tList
end booksSearch

on resizeStack
   -- (remaster) The window keeps one size, so this comes only if it is
   -- made resizable. The card "intro" is the front page now, which was
   -- laid out once, when the stack was made:
   --    send "layoutCard" to card "intro"
   send "layoutCard" to card "book data"
end resizeStack
