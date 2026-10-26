script "stack_SQLite_Tour_button_id_1236"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Edit Databases" (id 1206) > button "Add Row" (id 1236)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gConID
  local tColumnItems, tRowData, tSQL
  put "appName,appRegCode" into tColumnItems
  repeat for each item i in tColumnItems
    ask question "New value for column:" && i titled "Add Apps Row"
    if it is empty or the result is "Cancel" then exit to top
    put "'" & cleanSQL(it) & "'" & "," after tRowData
  end repeat
  ask question "Please enter a valid userID from table 'users':" with "1" titled "Add Apps Row"
  if it is empty or the result is "cancel" then exit to top
  put "'" & cleanSQL(it) & "'" after tRowData
  put "INSERT INTO apps(appID,appName,appRegCode,appUserID) VALUES(null," & tRowData & ")" into tSQL
  revExecuteSQL gConID,tSQL
  if the result is an integer then send "mouseUp" to btn "Refresh Apps"
  else answer warning the result with "OK" titled "Error"
end mouseUp

function cleanSQL pSQL
  replace "'" with "''" in pSQL
  return pSQL
end cleanSQL
