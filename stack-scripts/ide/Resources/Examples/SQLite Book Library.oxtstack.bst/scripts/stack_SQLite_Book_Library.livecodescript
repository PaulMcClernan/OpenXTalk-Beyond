script "stack_SQLite_Book_Library"
-- Stack file: ide/Resources/Examples/SQLite Book Library.oxtstack
-- Object: stack "SQLite Book Library"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sDatabaseID  --script local, available to handlers below, persists until quit
on preOpenStack
   local tName, tDatabaseFile, tTableSQL, tSQLStatement
   put the short name of this stack into tName
   put specialFolderPath("documents") & "/" & tName & ".sqlite" into tDatabaseFile
   if there is not a file tDatabaseFile then  --create db file
      put revOpenDatabase("sqlite",tDatabaseFile) into sDatabaseID
      put "CREATE TABLE books(BookID INTEGER PRIMARY KEY AUTOINCREMENT, Author varchar(255), Title varchar(255))" into tTableSQL
      revExecuteSQL sDatabaseID,tTableSQL
      --add some inital entries:
      put "INSERT into books(Author,Title) VALUES ('Tolkien J','Lord Of The Rings')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement
      put "INSERT into books(Author,Title) VALUES ('Austen J','Pride And Prejudice')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement
      put "INSERT into books(Author,Title) VALUES ('Baum F','Wizard Of Oz')" into tSQLStatement
      revExecuteSQL sDatabaseID,tSQLStatement
   else put revOpenDatabase("sqlite",tDatabaseFile) into sDatabaseID  --db file exists
   put dbListAll() into fld "Display"
end preOpenStack

function dbListAll  --retrieve all from database:
   local tSQLStatement
   put "SELECT * FROM books" into tSQLStatement
   return revDataFromQuery(tab,cr,sDatabaseID,tSQLStatement)
end dbListAll

function dbSearch pSearchTerm  --retrieve where title or author matches search term
   local tSQLStatement
   put "SELECT * FROM books WHERE author LIKE '%" & pSearchTerm & "%' OR title LIKE '%" & pSearchTerm & "%'" into tSQLStatement
   return revDataFromQuery(tab,cr,sDatabaseID,tSQLStatement)
end dbSearch

command AddRecord pAuthor, pTitle  --add a record
   local tSQLStatement
   put "INSERT INTO books(Author,Title) VALUES (" & quote & pAuthor & quote & comma & quote & pTitle & quote & ")" into tSQLStatement
   revExecuteSQL sDatabaseID,tSQLStatement
    put dbListAll() into fld "Display"
end AddRecord

command DeleteRecord pID  --delete a record
   local tSQLStatement
   put "DELETE FROM books WHERE BookID = '" & pID & "'" into tSQLStatement
   revExecuteSQL sDatabaseID,tSQLStatement
   put dbListAll() into fld "Display"
end DeleteRecord
