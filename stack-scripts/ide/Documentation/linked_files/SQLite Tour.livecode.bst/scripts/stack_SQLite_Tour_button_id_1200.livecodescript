script "stack_SQLite_Tour_button_id_1200"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Connecting To SQLite" (id 1091) > button "Delete Database File" (id 1200)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tPath
   answer question "Delete the database file AppRegister.sqlite?" with "Cancel" or "OK" titled "Delete Database"
   if it = "Cancel" then exit to top
   put specialFolderPath("desktop") & "/AppRegister.sqlite" into tPath
   if there is a file tPath then
      delete file tPath
      if the result = empty then answer "Successfully deleted the database file AppRegister.sqlite from the desktop." with "OK" titled "Delete Database"
      else answer warning the result with "OK" titled "Error"
   end if
end mouseUp
