script "stack_SQLite_Tour_button_id_1133"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Connecting To SQLite" (id 1091) > button "Disconnect" (id 1133)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   if gConID is empty then
      answer information "Sorry, the database is not connected. Please connect to the database first." with "OK" titled "Error"
      exit mouseUp
   end if
   revCloseDatabase gConID
   if "revdberr" is not in the result then
      answer information "Connection Terminated." with "OK" titled "Disconnect"
      put empty into gConID
   else answer warning the result with "OK" titled "Error"
end mouseUp
