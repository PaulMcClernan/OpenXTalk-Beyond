script "stack_Data_Grid_Templates_2026101801_button_id_1009"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > substack "Data Grid Templates 2026101801" > card (id 1005) > button "Behavior Script" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- This script defines the behavior of your data grid's custom template. This behavior
-- only applies to 'forms' and not 'tables'.

on FillInData pDataArray
   -- This message is sent when the Data Grid needs to populate
   -- this template with the data from a record. pDataArray is an
   -- an array containing the records data.
   -- You do not need to resize any of your template's controls in
   -- this message. All resizing should be handled in resizeControl.
   
   -- Example:
   set the text of field "Label" of me to pDataArray["label 1"]
end FillInData


on LayoutControl pControlRect, pWorkingRect
   local theFieldRect
   
   -- This message is sent when you should layout your template's controls.
   -- This is where you resize the 'Background' graphic, resize fields and 
   -- position objects.
   -- For fixed height data grid forms you can use items 1 through 4 of pControlRect as
   -- boundaries for laying out your controls.
   -- For variable height data grid forms you can use items 1 through 3 of pControlRect as
   -- boundaries, expanding the height of your control as needed.
   -- The working rect is defined area of the control you can safelt use.
   -- Use this rect to make sure your controls don't overlap with any edit mode controls.
   
   -- Example:
   put the rect of field "Label" of me into theFieldRect
   put item 1 of pWorkingRect into item 1 of theFieldRect
   put item 3 of pWorkingRect - 5 into item 3 of theFieldRect
   set the rect of field "Label" of me to theFieldRect
   
   set the rect of graphic "Background" of me to pControlRect
end LayoutControl


on ResetData
   -- Sent when data is being emptied because the control is no longer being used to display data
   set the text of field "Label" of me to empty
end ResetData


on PreFillInData
   -- Sent right before new data is going to replace existing data in the control
end PreFillInData


setprop dgHilite pBoolean
   -- This custom property is set when the highlight of your custom template has
   -- changed. By default the "Background" graphic will be highlighted for you. 
   -- You only add script here if you want to further customize the highlight.
   
   -- Example:
   if pBoolean then
      set the foregroundColor of me to the dgProp["hilited text color"] of the dgControl of me
   else
      set the foregroundColor of me to empty
   end if
end dgHilite


getprop dgDataControl
   -- Required by library so that it can locate your control.
   return the long ID of me
end dgDataControl


on mouseDoubleUp pMouseBtnNum
    local theKey
    
    -- Example of how to edit the contents of a field.
    -- By passing the index of the record associated with copy of this template being displayed and
    -- a key (array key) the data grid will automatically save the changes the user
    -- makes and refresh the UI by calling FillInData and resizeControl.
    if pMouseBtnNum is 1 then
        if the dgProps["allow editing"] of the dgControl of me then
            switch the short name of the target
                case "Label"
                    put "Label 1" into theKey
                    EditFieldText the long ID of the target, the dgIndex of me, theKey
                    break                 
            end switch
        end if
    end if
    
    pass mouseDoubleUp
end mouseDoubleUp
