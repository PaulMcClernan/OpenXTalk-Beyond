script "stack_Data_Grid_Tables_3"
-- Stack file: ide/Resources/Examples/Remastered/Data Grid Tables.oxtstack
-- Object: stack "Data Grid Tables" > card "Lesson 1" (id 1031) > group "Text > DG" (id 1239)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --text > dg
   local tText
   if fld "Display" = empty then
      answer "Sorry, there's no data in the field." with "OK" titled "Error"
      exit to top
   end if
   put fld "Display" into tText  --dg requires tab delimited data
   filter lines of tText without empty  --remove empty lines
   set the dgText of grp "DataGrid 1" to tText
end mouseUp

----
--set the opaque of fld "Colors 0003" of grp "Datagrid 1" to "true"  --allow color
--set the backColor of fld "Colors 0003" of grp "Datagrid 1" to "pink"  --color a cell
----
--dg table properties inspector > columns > select a column to color, click btn "Column Behavior",
--paste in the column's "column behavior" button script:
on FillInData pData  --dg table conditional text color
   set the text of fld 1 of me to pData
   if pData >= "3" then set the textColor of fld 1 of me to "Red"
   else set the textColor of fld 1 of me to empty  --default black
end FillInData
