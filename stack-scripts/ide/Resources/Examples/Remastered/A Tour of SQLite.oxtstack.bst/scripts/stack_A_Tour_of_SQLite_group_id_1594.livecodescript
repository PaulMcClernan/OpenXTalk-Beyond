script "stack_A_Tour_of_SQLite_group_id_1594"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "The Schema" (id 1041) > group "Default Data" (id 1594)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tConId, tPath, tSQL, tList, tLine
   if gConID = empty then  --connect
      put specialFolderPath("temporary") & "/AppRegister.sqlite" into tPath  --(the original used the desktop)
      put revOpenDatabase("sqlite",tPath,,,,,,) into tConID
      if the result is an integer then
         put tConID into gConID
         showResult "ok", "AppRegister Connected! Your connection ID is:" && tConID &"."
      else
         showResult "error", "Sorry, there was a problem creating or accessing the database." &cr& the result
         exit to top
      end if
   end if
   answer "Inserting default data will delete existing data in the database." with "Cancel" or "OK" titled "Default Data"
   if it = "Cancel" then exit mouseUp
   --(revExecuteSQL's errors do not say "revdberr", which the original looked for: the result is not
   --an integer then. So the tables are dropped IF EXISTS, as a new database has none to drop)
   put "DROP TABLE IF EXISTS users" into tSQL
   revExecuteSQL gConID, tSQL
   if the result is not an integer then
      showResult "error", the result
      exit mouseUp
   end if
   --
   put "DROP TABLE IF EXISTS apps" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is not an integer then
      showResult "error", the result
      exit mouseUp
   end if
   --
   put "CREATE TABLE users(userID integer primary key,name text,email text,emailList boolean)" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is not an integer then
      showResult "error", the result
      exit mouseUp
   end if
   --
   put "CREATE TABLE apps(appID integer primary key,appName text,appRegCode text,appUserID integer)" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is not an integer then
      showResult "error", the result
      exit mouseUp
   end if
   --answer information "New tables: users and apps created." with "OK" titled "Default Data"
   --
   put the altDefaultUsersData of me into tList
   repeat for each line tLine in tList
      put "INSERT INTO users(userID,name,email,emailList) VALUES(null," & tLine & ")" into tSQL
      revExecuteSQL gConID,tSQL
      if the result is not an integer then
         showResult "error", the result
         exit mouseUp
      end if
   end repeat
   --
   put the altDefaultAppsData of me into tList
   repeat for each line tLine in tList
      put "INSERT INTO apps(appID, appName, appRegCode, appUserID) VALUES(null," & tLine & ")" into tSQL
      revExecuteSQL gConID,tSQL
      if the result is not an integer then
         showResult "error", the result
         exit mouseUp
      end if
   end repeat
   showResult "ok", "Default data has been successfully inserted."
end mouseUp

function cleanSQL pSQL
   replace "'" with "''" in pSQL
   --(the original also doubled double quotes, which SQL keeps as they are between single quotes)
   replace cr with "*CR*" in pSQL
   replace tab with "*TAB*" in pSQL
   return pSQL
end cleanSQL
