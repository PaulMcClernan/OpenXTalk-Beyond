script "stack_SQLite_Books_card_id_1031"
-- Stack file: ide/Resources/Examples/Remastered/SQLite Books.oxtstack
-- Object: stack "SQLite Books" > card "Library" (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(remaster) a space after each comma of the database calls, so that the scripts panel can wrap them
local sDatabaseID  --script local, available to handlers below, persists until quit

on preOpenCard  --was preOpenStack, in the stack script
   local tName, tDatabaseFile, tTableSQL, tSQLStatement
   if sDatabaseID is an integer then  --added: open already, the last time this card opened
      put dbListAll() into fld "Display"
      pass preOpenCard
   end if
   if not dbLoaded() then  --added: a word, not a script error, where the database library is not loaded
      put "The database library, revDB, is not loaded here." into sDatabaseID
      put dbListAll() into fld "Display"
      pass preOpenCard
   end if
   put the short name of this stack into tName
   put dbFolder() & "/" & tName & ".sqlite" into tDatabaseFile
   if there is not a file tDatabaseFile then  --create db file
      put revOpenDatabase("sqlite", tDatabaseFile) into sDatabaseID
      if sDatabaseID is an integer then  --added: it opened (else the Display field says why)
         put "CREATE TABLE books(BookID INTEGER PRIMARY KEY AUTOINCREMENT, Author varchar(255), Title varchar(255))" into tTableSQL
         revExecuteSQL sDatabaseID, tTableSQL
         --add some inital entries:
         put "INSERT into books(Author,Title) VALUES ('Tolkien J','Lord Of The Rings')" into tSQLStatement
         revExecuteSQL sDatabaseID, tSQLStatement
         put "INSERT into books(Author,Title) VALUES ('Austen J','Pride And Prejudice')" into tSQLStatement
         revExecuteSQL sDatabaseID, tSQLStatement
         put "INSERT into books(Author,Title) VALUES ('Baum F','Wizard Of Oz')" into tSQLStatement
         revExecuteSQL sDatabaseID, tSQLStatement
      end if
   else put revOpenDatabase("sqlite", tDatabaseFile) into sDatabaseID  --db file exists
   put dbListAll() into fld "Display"
   pass preOpenCard  --added: the window lays out this card after it
end preOpenCard

function dbFolder  --added: where the database goes, the documents folder (the stack's own may not be writable)
   local tFolder
   put specialFolderPath("documents") into tFolder
   if tFolder is empty or there is not a folder tFolder then put specialFolderPath("temporary") into tFolder
   return tFolder
end dbFolder

function dbLoaded  --added: true if revDB is loaded (the IDE loads it, and the web engine has it built in)
   local tError
   try
      get revOpenDatabases()
   catch tError
      return false
   end try
   return true
end dbLoaded

function dbProblem  --added: what the Display field says when there is no database
   return "Sorry, the library could not open its database." &cr& sDatabaseID
end dbProblem

function dbListAll  --retrieve all from database:
   local tSQLStatement
   if sDatabaseID is not an integer then return dbProblem()  --added
   put "SELECT * FROM books" into tSQLStatement
   return revDataFromQuery(tab, cr, sDatabaseID, tSQLStatement)
end dbListAll

function dbSearch pSearchTerm  --retrieve where title or author matches search term
   local tSQLStatement, tLike
   if sDatabaseID is not an integer then return dbProblem()  --added
   --a placeholder (:1) for the search term, so that a quote in it cannot break the statement; it was:
   --put "SELECT * FROM books WHERE author LIKE '%" & pSearchTerm & "%' OR title LIKE '%" & pSearchTerm & "%'" into tSQLStatement
   put "%" & pSearchTerm & "%" into tLike
   put "SELECT * FROM books WHERE author LIKE :1 OR title LIKE :1" into tSQLStatement
   return revDataFromQuery(tab, cr, sDatabaseID, tSQLStatement, "tLike")
end dbSearch

command AddRecord pAuthor, pTitle  --add a record
   local tSQLStatement
   if sDatabaseID is not an integer then exit AddRecord  --added
   --placeholders (:1, :2) for the author and the title, as in dbSearch; it was:
   --put "INSERT INTO books(Author,Title) VALUES (" & quote & pAuthor & quote & comma & quote & pTitle & quote & ")" into tSQLStatement
   put "INSERT INTO books(Author,Title) VALUES (:1, :2)" into tSQLStatement
   revExecuteSQL sDatabaseID, tSQLStatement, "pAuthor", "pTitle"
   put dbListAll() into fld "Display"
end AddRecord

command DeleteRecord pID  --delete a record
   local tSQLStatement
   if sDatabaseID is not an integer then exit DeleteRecord  --added
   put "DELETE FROM books WHERE BookID = '" & pID & "'" into tSQLStatement
   revExecuteSQL sDatabaseID, tSQLStatement
   put dbListAll() into fld "Display"
end DeleteRecord
