script "stack_SQLite_Tour_button_id_1093"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Connecting To SQLite" (id 1091) > button "Connect To AppRegister" (id 1093)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tConId, tPath
   put specialFolderPath("desktop") & "/AppRegister.sqlite" into tPath
   put revOpenDatabase("sqlite",tPath,,,,,,) into tConID
   if the result is an integer then
      answer information "AppRegister Connected! Your connection ID is:" && tConID &"." with "OK" titled "Connected"
      put tConID into gConID
   else answer warning "Sorry, there was a problem creating or accessing the database." &cr& the result with "OK" titled "Error"
end mouseUp
