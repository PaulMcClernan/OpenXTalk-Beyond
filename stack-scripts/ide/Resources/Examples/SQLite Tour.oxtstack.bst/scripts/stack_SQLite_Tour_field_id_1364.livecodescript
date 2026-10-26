script "stack_SQLite_Tour_field_id_1364"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Update Data" (id 1363) > field "Users" (id 1364)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on selectionChanged
   global gConID
   local tLineNum, tXLoc, tTabStops, tIncrement, tClickedText, tUserID, tColumnToUpdate, tNewValue, tSQL
   if the lockText of me = "false" then exit to top
   put word 2 of the clickLine into tLineNum
   put item 1 of the clickLoc into tXLoc
   subtract the left of me from tXLoc
   put the tabStops of me into tTabStops
   repeat until last item of tTabStops > tXLoc
      put last item of tTabStops - item -2 of tTabStops into tIncrement
      put "," & last item of tTabStops + tIncrement after tTabStops
   end repeat
   put 1 into x
   repeat while item x of tTabStops < tXLoc
      add 1 to x
   end repeat 
   set itemDel to tab
   put item x of line tLineNum of me into tClickedText
   put item 1 of line tLineNum of me into tUserID
   --create SQL string
   switch x
      case "1" --> userID
         answer warning "Sorry, can't change a Primary Key" with "OK" titled "Error"
         exit to top
         break
      case "2" --> name
         put "name" into tColumnToUpdate
         break
      case "3" --> email
         put "email" into tColumnToUpdate
         break
      case "4" --> emailList
         put "emailList" into tColumnToUpdate
         break
   end switch
   --
   ask "New value for " & tColumnToUpdate &":" with tClickedText
   if it is empty or the result is "Cancel" then exit to top
   put "'" & cleanSQL(it) & "'" into tNewValue
   put "UPDATE users SET " & tColumnToUpdate & "=" & tNewValue & " WHERE userID=" & tUserID into tSQL
   revExecuteSQL gConID,tSQL
   if the result is not an integer then
      answer warning the result with "OK" titled "Error"
      exit to top
   else send mouseUp to btn "Refresh Table"  --display change
end selectionChanged

function cleanSQL pSQL
  replace "'" with "''" in pSQL
  replace quote with quote & quote in pSQL
  replace cr with "*CR*" in pSQL
  replace tab with "*TAB*" in pSQL
  return pSQL
end cleanSQL
