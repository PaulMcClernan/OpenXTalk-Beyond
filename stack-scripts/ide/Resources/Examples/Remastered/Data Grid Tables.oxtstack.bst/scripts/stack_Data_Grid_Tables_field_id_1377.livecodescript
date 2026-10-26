script "stack_Data_Grid_Tables_field_id_1377"
-- Stack file: ide/Resources/Examples/Remastered/Data Grid Tables.oxtstack
-- Object: stack "Data Grid Tables" > card "Lesson 4" (id 1034) > field "Try It" (id 1377)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --added: runs the line you click, as the message box runs a line you type and Return
   local tLine, tParts, tIndex, tStatement, tScript, tResult, tError
   put the value of the clickLine into tLine
   if word 1 to -1 of tLine is empty then exit mouseUp
   put tLine into tParts
   split tParts by ";"
   repeat with tIndex = 1 to the number of elements of tParts
      put word 1 to -1 of tParts[tIndex] into tStatement
      if word 1 of tStatement is "put" and " into " is not in tStatement and " after " is not in tStatement and " before " is not in tStatement then
         put " into tResult" after tStatement  --what would go to the message box goes to this card's
      end if
      put tStatement & return after tScript
   end repeat
   put "Done." into tResult
   try
      do tScript
   catch tError
      put "Sorry, that line did not run here." into tResult
   end try
   if there is a fld "Message" then put tResult into fld "Message"  --on the card (a line may go to another)
end mouseUp
