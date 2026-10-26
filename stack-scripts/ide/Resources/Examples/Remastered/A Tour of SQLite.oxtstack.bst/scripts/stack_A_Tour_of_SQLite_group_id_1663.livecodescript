script "stack_A_Tour_of_SQLite_group_id_1663"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Binary Data" (id 1043) > group "Insert" (id 1663)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(the original's "Insert Binary Data")
on mouseUp
   global gConID
   local tPath, tConId, tSQL, tName, tEmail, tIcon, tList
   answer information "This will insert binary data into table 'example' in file 'BinaryTest.sqlite'." with "Cancel" or "OK" titled "Insert Binary Data"
   if it = "Cancel" then exit to top
   --disconnect old
   if gConID <> empty then
      revCloseDatabase gConID
      if "revdberr" is in the result then
         showResult "error", the result
         exit to top
      else put empty into gConID
   end if
   --connect new
   put specialFolderPath("temporary") & "/BinaryTest.sqlite" into tPath  --(the original used the desktop)
   if there is a file tPath then delete file tPath  --delete old file
   put revOpenDatabase("sqlite",tPath,,,,,,) into tConID
   if the result is not an integer then
      showResult "error", "Sorry, there was a problem creating or accessing the database." &cr& the result
      exit to top
   else put tConID into gConID
   --create table
   put "CREATE TABLE example(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NULL,email TEXT NULL,icon BLOB NULL)" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is not an integer then
      showResult "error", "Sorry, there was a problem creating the table." &cr& the result
      exit to top
   end if
   --insert data
   put "John Smith" into tName
   put "john@ibm.com" into tEmail
   if there is not an image "Icon1" then showResult "error", "Sorry, could not find image 'Icon1' for binary data."
   else put the text of image "Icon1" into tIcon  --binary data of image
   put "INSERT INTO example(name,email,icon) VALUES (:1,:2,:3)" into tSQL
   revExecuteSQL gConID,tSQL,"tName","tEmail","*btIcon"  --quoted variables, *b for binary data
   if the result is not an integer then
      showResult "error", "Sorry, there was a problem inserting data into the table." &cr& the result
      exit to top
   end if
   --display non-binary data
   put "SELECT name,email FROM example" into tSQL  --non-binary data
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      showResult "error", the result
      exit mouseUp
   end if
   put tList into field "Example"  --(the original answered with it)
   showResult "ok", "A new row containing binary data has been added to table 'example'." & return & \
         "Its icon column holds the" && the number of bytes of tIcon && "bytes of image Icon1."
end mouseUp
