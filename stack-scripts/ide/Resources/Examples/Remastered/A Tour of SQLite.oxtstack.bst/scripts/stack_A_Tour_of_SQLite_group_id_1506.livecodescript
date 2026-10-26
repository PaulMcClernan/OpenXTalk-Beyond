script "stack_A_Tour_of_SQLite_group_id_1506"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Both Tables" (id 1039) > group "Add App" (id 1506)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(the original's "Add Row" of the table apps)
on mouseUp
   global gConID
   local tColumnItems, tRowData, tSQL, i
   if gConID = empty then  --(added, as the other buttons do)
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   put "appName,appRegCode" into tColumnItems
   repeat for each item i in tColumnItems
      ask question "New value for column:" && i titled "Add Apps Row"
      if it is empty or the result is "Cancel" then exit to top
      put "'" & cleanSQL(it) & "'" & "," after tRowData
   end repeat
   ask question "Please enter a valid userID from table 'users':" with "1" titled "Add Apps Row"
   if it is empty or the result is "cancel" then exit to top
   put "'" & cleanSQL(it) & "'" after tRowData
   put "INSERT INTO apps(appID, appName, appRegCode, appUserID) VALUES(null," & tRowData & ")" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then send "mouseUp" to group "Refresh Apps"
   else showResult "error", the result
end mouseUp

function cleanSQL pSQL
   replace "'" with "''" in pSQL
   return pSQL
end cleanSQL
