script "stack_Data_Grid_Tour_card_id_5539"
-- Stack file: ide/Resources/Examples/Data Grid Tour.oxtstack
-- Object: stack "Data Grid Tour" > card "Form" (id 5539)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## STEP 1
on loadData
   local tHeaders, tData, tLine, tKey1, tKey2, tCount
   ## 1: The headers and data for the form are loaded from custom properties on this card.
   put the cHeaders of this card into tHeaders
   put the cData of this card into tData
   ## 2: The data is multiple rows each containing items separated by the tab character.
   ## 2: Set the itemDelimiter to tab to repeat over each item.
   set the itemDelimiter to tab
   ## 3: Iterate through each line in the data.
   repeat for each line tLine in tData
      add 1 to tKey1
      put 0 into tCount
      ## 4: Iterate over each item in the header names.
      repeat for each item tKey2 in tHeaders 
         add 1 to tCount
         ## 5: Put the current item of the current line into the two-dimensional array.
         ## 5: KEY 1 : The line number, an integer from 1 to x.
         ## 5: KEY 2 : The name of the header, a key word that holds the value.
         ## 5: DATA : The current item in the current line of data.
         put item tCount of tLine into theDataArray[tKey1][tKey2]
      end repeat
   end repeat
   ## 6: Load the array data into the data grid by setting the dgData property.
   set the dgData of group "SampleForm" to theDataArray
end loadData

## STEP 2
on formatForm
   ## 3: Set the row colors to match the background.
   set the dgProps["row color"] of group "SampleForm" to "#E6F6FE"
   set the dgProps["alternate row color"] of group "SampleForm" to "#7FC9E8"
end formatForm

## STEP 0
on resetDemonstration
   ## This function resets all the properties back to their original setting.
   set the dgData of group "SampleForm" to ""
   set the dgProps["row color"] of group "SampleForm" to "#ffffff"
   set the dgProps["alternate row color"] of group "SampleForm" to "#E6EDF7"
end resetDemonstration

## OTHER FUNCTION AND HANDLERS

on stepSet pStep
   ## This function iterates over the step 'buttons' on the interface and fades out
   ## the ones which have not been applied.
   repeat with x = 0 to 2
      if x <= pStep then set the blendlevel of button ("Step" & x) to 0
      else set the blendlevel of button ("Step" & x) to 50
   end repeat
end stepSet

on preopencard
   ## Resets the demonstration and sets the stage to 0.
   resetDemonstration
   stepSet 0
end preopencard
