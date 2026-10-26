script "stack_SQLite_Tour_button_id_1355"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Binary Data" (id 1304) > button "Insert Binary Data" (id 1355)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tPath, tConId, tSQL, tName, tEmail, tIcon, tList
   answer information "This will insert binary data into table 'example' in file 'BinaryTest.sqlite'." with "Cancel" or "OK" titled "Insert Binary Data"
   if it = "Cancel" then exit to top
   --disconnect old
   if gConID <> empty then
      revCloseDatabase gConID
      if "revdberr" is in the result then
         answer warning the result with "OK" titled "Error"
         exit to top
      else put empty into gConID
   end if
   --connect new
   put specialFolderPath("desktop") & "/BinaryTest.sqlite" into tPath
   if there is a file tPath then delete file tPath  --delete old file
   put revOpenDatabase("sqlite",tPath,,,,,,) into tConID
   if the result is not an integer then
      answer warning "Sorry, there was a problem creating or accessing the database." &cr& the result with "OK" titled "Error"
      exit to top
   else put tConID into gConID
   --create table
   put "CREATE TABLE example(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NULL,email TEXT NULL,icon BLOB NULL)" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is not an integer then
      answer warning "Sorry, there was a problem creating the table." &cr& the result with "OK" titled "Error"
      exit to top
   end if
   --insert data
   put "John Smith" into tName
   put "john@ibm.com" into tEmail
   if there is not an image "Icon1" then answer "Sorry, could not find image 'Icon1' for binary data." with "OK" titled "Error"
   else put the text of image "Icon1" into tIcon  --binary data of image
   put "INSERT INTO example(name,email,icon) VALUES (:1,:2,:3)" into tSQL
   revExecuteSQL gConID,tSQL,"tName","tEmail","*btIcon"  --quoted variables, *b for binary data
   if the result is not an integer then
      answer warning "Sorry, there was a problem inserting data into the table." &cr& the result with "OK" titled "Error"
      exit to top
   else answer information "A new row containing binary data has been added to table 'example'." with "OK" titled "Insert Binary Data"
   --display non-binary data
   put "SELECT name,email FROM example" into tSQL  --non-binary data
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   replace tab with comma in tList  --for answer dialog
   answer information "Records returned:" &cr& tList with "OK" titled "Table Example (non-binary)"
end mouseUp
