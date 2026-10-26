script "stack_SQLite_Tour_button_id_1237"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Edit Databases" (id 1206) > button "Default Data" (id 1237)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local  tConId, tPath, tSQL, tList
   if gConID = empty then  --connect
      put specialFolderPath("desktop") & "/AppRegister.sqlite" into tPath
      put revOpenDatabase("sqlite",tPath,,,,,,) into tConID
      if the result is an integer then
         answer information "AppRegister Connected! Your connection ID is:" && tConID &"." with "OK" titled "Connected"
         put tConID into gConID
      else
         answer warning "Sorry, there was a problem creating or accessing the database." &cr& the result with "OK" titled "Error"
         exit to top
      end if
   end if
   answer "Inserting default data will delete existing data in the database." with "Cancel" or "OK" titled "Default Data"
   if it = "Cancel" then exit mouseUp
   --
   put "DROP TABLE users" into tSQL
   revExecuteSQL gConID, tSQL
   if "revdberr" is in the result then 
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   --
   put "DROP TABLE apps" into tSQL
   revExecuteSQL gConID,tSQL
   if "revdberr" is in the result then 
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   --
   put "CREATE TABLE users(userID integer primary key,name text,email text,emailList boolean)" into tSQL
   revExecuteSQL gConID,tSQL
   if "revdberr" is in the result then 
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   --
   put "CREATE TABLE apps(appID integer primary key,appName text,appRegCode text,appUserID integer)" into tSQL
   revExecuteSQL gConID,tSQL
   if "revdberr" is in the result then 
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   --answer information "New tables: users and apps created." with "OK" titled "Default Data"
   --
   put the altDefaultUsersData of me into tList 
   repeat for each line tLine in tList
      put "INSERT INTO users(userID,name,email,emailList) VALUES(null," & tLine & ")" into tSQL
      revExecuteSQL gConID,tSQL
      if "revdberr" is in the result then 
         answer warning the result with "OK" titled "Error"
         exit mouseUp
      end if
   end repeat
   --
   put the altDefaultAppsData of me into tList
   repeat for each line tLine in tList
      put "INSERT INTO apps(appID,appName,appRegCode,appUserID) VALUES(null," & tLine & ")" into tSQL
      revExecuteSQL gConID,tSQL
      if "revdberr" is in the result then 
         answer warning the result with "OK" titled "Error"
         exit mouseUp
      end if
   end repeat
   --
   send "mouseUp" to btn "Refresh Users"
   send "mouseUp" to btn "Refresh Apps"
end mouseUp

function cleanSQL pSQL
  replace "'" with "''" in pSQL
  replace quote with quote & quote in pSQL
  replace cr with "*CR*" in pSQL
  replace tab with "*TAB*" in pSQL
  return pSQL
end cleanSQL
