script "stack_A_Tour_of_SQLite_group_id_1667"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Binary Data" (id 1043) > group "Retrieve" (id 1667)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(the original's "Retrieve Binary Data")
on mouseUp
   global gConID
   local tPath, tConID, tSQL, tRecordSetID, tIcon, tTemp
   --This will retrieve binary data from table 'example' in file 'BinaryTest.sqlite'.
   --(The original asked first, in a dialog: the panel says it now.)
   --connect
   put specialFolderPath("temporary") & "/BinaryTest.sqlite" into tPath  --(the original used the desktop)
   if there is not a file tPath then
      showResult "error", "Sorry, please insert binary data first."
      exit to top
   else if gConID = empty then
      put revOpenDatabase("sqlite",tPath,,,,,,) into tConID
      if the result is not an integer then
         showResult "error", "Sorry, there was a problem creating or accessing the database." &cr& the result
         exit to top
      else put tConID into gConID
   end if
   --
   put "SELECT icon FROM example WHERE id=1" into tSQL  --first row of table
   put revQueryDatabase(gConID,tSQL) into tRecordSetID  --an integer
   if the result is not an integer then
      showResult "error", the result
      exit to top
   end if
   --retrieve binary data using tRecordSetID
   put revDatabaseColumnNamed(tRecordSetID, "icon", "tIcon") into tTemp  --holder variable required for binary data
   if "revdberr" is in the result then
      showResult "error", the result
      exit to top
   end if
   revCloseCursor tRecordSetID  --(added: a record set is closed when you are done with it)
   if there is not an image "Icon2" then showResult "error", "Sorry, could not find image 'Icon2'."
   else
      set the text of image "Icon2" to tIcon  --display binary data
      showResult "ok", "Icon2 shows the" && the number of bytes of tIcon && "bytes read back from the database."  --(added)
   end if
end mouseUp
