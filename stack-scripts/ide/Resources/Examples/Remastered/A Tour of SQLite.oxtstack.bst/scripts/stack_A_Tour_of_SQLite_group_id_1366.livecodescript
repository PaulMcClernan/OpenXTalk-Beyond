script "stack_A_Tour_of_SQLite_group_id_1366"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Connect" (id 1034) > group "Delete File" (id 1366)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tPath
   answer question "Delete the database file AppRegister.sqlite?" with "Cancel" or "OK" titled "Delete Database"
   if it = "Cancel" then exit to top
   put specialFolderPath("temporary") & "/AppRegister.sqlite" into tPath  --(the original used the desktop)
   if gConID is not empty then  --(added: a file the database has open cannot be deleted everywhere)
      revCloseDatabase gConID
      put empty into gConID
   end if
   if there is a file tPath then
      delete file tPath
      if the result = empty then showResult "ok", "Successfully deleted the database file AppRegister.sqlite."
      else showResult "error", the result
   else showResult "info", "There is no database file to delete yet."  --(added)
end mouseUp
