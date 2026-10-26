script "stack_A_Tour_of_SQLite_group_id_1358"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Connect" (id 1034) > group "Connect" (id 1358)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tConId, tPath
   put specialFolderPath("temporary") & "/AppRegister.sqlite" into tPath  --a folder you can write to (the original used the desktop)
   put revOpenDatabase("sqlite",tPath,,,,,,) into tConID
   if the result is an integer then
      put tConID into gConID  --(first, so that the panel shows the connection)
      showResult "ok", "AppRegister Connected! Your connection ID is:" && tConID &"."
   else showResult "error", "Sorry, there was a problem creating or accessing the database." &cr& the result
end mouseUp
