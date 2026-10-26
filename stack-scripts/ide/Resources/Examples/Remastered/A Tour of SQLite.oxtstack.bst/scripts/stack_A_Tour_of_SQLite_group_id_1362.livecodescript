script "stack_A_Tour_of_SQLite_group_id_1362"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Connect" (id 1034) > group "Disconnect" (id 1362)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   if gConID is empty then
      showResult "error", "Sorry, the database is not connected. Please connect to the database first."
      exit mouseUp
   end if
   revCloseDatabase gConID
   if "revdberr" is not in the result then
      put empty into gConID  --(first, so that the panel shows it closed)
      showResult "ok", "Connection Terminated."
   else showResult "error", the result
end mouseUp
