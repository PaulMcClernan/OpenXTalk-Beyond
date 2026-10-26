script "stack_Data_Grid_Tour_card_id_5536"
-- Stack file: ide/Resources/Examples/Data Grid Tour.oxtstack
-- Object: stack "Data Grid Tour" > card "Table" (id 5536)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## STEP 1
on loadData
   ## 1: Set the data of the grid. (This is stored in a custom property of this card).
   set the dgText of group "SampleTable" to the cData of this card
end loadData

## STEP 2
on columnsSetNames
   ## 1: Set the column names of the data grid.
   set the dgProps["columns"] of group "SampleTable" to "Rank" & return & "City" & return & "Country" & return & "IconID"
end columnsSetNames

## STEP 3
on columnsSetLook
   ## 1: Make the headers stand out a little more by making the text bold.
   set the dgProps["header text style"] of group "SampleTable" to "bold"
   ## 2: Set the column widths to fit the data nicely.
   set the dgColumnWidth["Rank"] of group "SampleTable" to "50" 
   set the dgColumnWidth["City"] of group "SampleTable" to "130"
   set the dgColumnWidth["Country"] of group "SampleTable" to "98"
   ## 3: Make the final column invisible because it is not data useful to the end use.
   set the dgColumnIsVisible["IconID"] of group "SampleTable" to "false"
end columnsSetLook

## STEP 4
on columnsSetOrder
   ## 1: Set the column data type to 'numeric' so that ordering works correctly.
   ## 1: By default a column will act as text.
   set the dgColumnSortType["Rank"] of group "SampleTable" to "Numeric"
   ## 2: Sort the data by column 1.
   set the dgProps["sort by column"] of group "SampleTable" to "Rank"
   ## 3: Set the row colors to match the background.
   set the dgProps["row color"] of group "SampleTable" to "#E6F6FE"
   set the dgProps["alternate row color"] of group "SampleTable" to "#7FC9E8"
   ## 4: Now that columns are setup, disable resizing.
   set the dgColumnIsResizable["Rank"] of group "SampleTable" to false
   set the dgColumnIsResizable["City"] of group "SampleTable" to false
   set the dgColumnIsResizable["Country"] of group "SampleTable" to false
end columnsSetOrder

## STEP 5
on columnsAddFlags
   ## Change row template with country flags, adjust column widths.
   put the dgProps["row template"] of group "SampleTable" into tTemplateID
   put tTemplateID into tCardID
   repeat while word 1 of tCardID is not "card"
      delete word 1 of tCardID
   end repeat
   copy group "Country" of tCardID to tTemplateID
   send "resetList" to group "SampleTable"
   set the dgColumnWidth["City"] of group "SampleTable" to "174"
   set the dgColumnWidth["Country"] of group "SampleTable" to "55"
end columnsAddFlags

## STEP 0
on resetDemonstration
   ## This function resets all the properties back to their original setting.
   set the dgProps["columns"] of group "SampleTable" to ""
   set the dgText of group "SampleTable" to ""
   
   set the dgProps["header text style"] of group "SampleTable" to "normal"
   set the dgProps["row color"] of group "SampleTable" to "#ffffff"
   set the dgProps["alternate row color"] of group "SampleTable" to "#E6EDF7"
   
   put the dgProps["row template"] of group "SampleTable" into tTemplateID
   if there is a group "Country" of tTemplateID then delete group "Country" of tTemplateID
end resetDemonstration


## OTHER FUNCTION AND HANDLERS

on stepSet pStep
   ## This function iterates over the step 'buttons' on the interface and fades out
   ## the ones which have not been applied
   repeat with x = 0 to 5
      if x <= pStep then set the blendlevel of button ("Step" & x) to 0
      else set the blendlevel of button ("Step" & x) to 50
   end repeat
end stepSet

on preopencard
   ## Resets the demonstration and sets the stage to 0
   resetDemonstration
   stepSet 0
end preopencard
