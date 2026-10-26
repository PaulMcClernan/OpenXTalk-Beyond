script "stack_SQLite_Tour_button_id_1360"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Binary Data" (id 1304) > button "Retrieve Binary Data" (id 1360)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tPath, tConID, tSQL, tRecordSetID, tIcon
   answer information "This will retrieve binary data from table 'example' in file 'BinaryTest.sqlite'." with "Cancel" or "OK" titled "Retrieve Binary Data"
   if it = "Cancel" then exit to top
   --connect
   put specialFolderPath("desktop") & "/BinaryTest.sqlite" into tPath
   if there is not a file tPath then
      answer "Sorry, please insert binary data first." with "OK" titled "Error"
      exit to top
   else if gConID = empty then 
      put revOpenDatabase("sqlite",tPath,,,,,,) into tConID
      if the result is not an integer then
         answer warning "Sorry, there was a problem creating or accessing the database." &cr& the result with "OK" titled "Error"
         exit to top
      else put tConID into gConID
   end if
   --
   put "SELECT icon FROM example WHERE id=1" into tSQL  --first row of table
   put revQueryDatabase(gConID,tSQL) into tRecordSetID  --an integer
   if the result is not an integer then
      answer warning the result with "OK" titled "Error"
      exit to top
   end if
   --retrieve binary data using tRecordSetID
   put revDatabaseColumnNamed(tRecordSetID,"icon","tIcon") into tTemp  --holder variable required for binary data
   if "revdberr" is in the result then
      answer warning the result with "OK" titled "Error"
      exit to top
   end if
   if there is not an image "Icon2" then answer "Sorry, could not find image 'Icon2'." with "OK" titled "Error"
   else set the text of image "Icon2" to tIcon  --display binary data
end mouseUp
