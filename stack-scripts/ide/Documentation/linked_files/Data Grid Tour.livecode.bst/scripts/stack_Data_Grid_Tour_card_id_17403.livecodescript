script "stack_Data_Grid_Tour_card_id_17403"
-- Stack file: ide/Documentation/linked_files/Data Grid Tour.livecode
-- Object: stack "Data Grid Tour" > card "The Template" (id 17403)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## This script works by repeatedly setting the data of the grid. In effect, 
## adding an extra row of data to the grid every 3/4 of a second until 8 rows are filled.

## Script locals track the current number of rows displayed and have the data array.
local sDataArray
local sRowCount

## Set the row count to 0 and the demo starts.
on openCard
   put 0 into sRowCount
   demonstrationStart 
   pass openCard
end openCard

## The demonstrationPrepare command is taking the data and header information stored
## in a custom property on this card and processing it into a two-dimension array the data grid can understand.
on demonstrationPrepare pRowCount
   local tHeaders, tData, tKey1, tKey2, tLine, tCount
   put the cHeader of this card into tHeaders
   put the cData of this card into tData
   put empty into sDataArray
   set the itemDelimiter to tab
   put 0 into tKey1
   repeat for each line tLine in tData
      add 1 to tKey1
      if tKey1 <= sRowCount then
         put 0 into tCount
         repeat for each item tKey2 in tHeaders 
            add 1 to tCount
            put item tCount of tLine into sDataArray[tKey1][tKey2]
            put "false" into sDataArray[tKey1]["expanded"]
         end repeat
      end if
   end repeat
end demonstrationPrepare

on demonstrationStart
   ## Check that the user is still on this card.
   if the short name of this card is "The Template" then 
      ## After displaying 8 rows or more, stop the demo.
      if sRowCount > 8 then 
         --put 0 into sRowCount  --loop demo until user leaves card.
         exit to top  --stop demo.
      end if
      add 1 to sRowCount
      ## Prepare the data to insert into the data grid.
      demonstrationPrepare sRowCount
      ## Set the data in the data grid.
      set the dgData of group "SlowLoadingGrid" to sDataArray
      ## Add another row to the grid in 3/4 of a second.
      send demonstrationStart to me in 750 milliseconds
   end if
end demonstrationStart
