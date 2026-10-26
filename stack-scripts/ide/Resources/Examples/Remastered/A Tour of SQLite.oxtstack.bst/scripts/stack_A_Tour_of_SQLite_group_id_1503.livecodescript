script "stack_A_Tour_of_SQLite_group_id_1503"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Both Tables" (id 1039) > group "Delete App" (id 1503)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(the original's "Delete Row" of the table apps)
on mouseUp
   global gConID
   local tNum, tAppID, tSQL
   put the hilitedLine of fld "Apps" into tNum
   if tNum is empty or line tNum of fld "Apps" is empty then  --(added: no row chosen, or an empty one)
      showResult "info", "Choose a row of apps first."  --(added)
      exit mouseUp
   end if
   set the itemDel to tab
   put item 1 of line tNum of fld "Apps" into tAppID
   put "DELETE FROM apps WHERE appID=" & tAppID into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then send "mouseUp" to group "Refresh Apps"
   else showResult "error", the result
end mouseUp
