script "stack_Data_Grid_Templates_1238425995346_button_id_1028"
-- Stack file: ide/Documentation/linked_files/Data Grid Tour.livecode
-- Object: stack "Data Grid Tour" > substack "Data Grid Templates 1238425995346" > card (id 1024) > button "Behavior Script" (id 1028)
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


on LayoutControl
    local theFieldRect,theMasterRect
    
    -- This message is sent when you should layout your template's controls.
    -- This is where you resize the 'Background' graphic, resize fields and 
    -- position objects.
    -- The first thing you should do is capture 'the rect of me'.
    -- For fixed height data grid forms you can use items 1 through 4 of the rect as
    -- boundaries for laying out your controls.
    -- For variable height data grid forms you can use items 1 through 3 of the rect as
    -- boundaries.
    
    put the rect of me into theMasterRect
    
    -- Example:
    put the rect of field "Label" of me into theFieldRect
    put item 3 of theMasterRect - 5 into item 3 of theFieldRect
    set the rect of field "Label" of me to theFieldRect
    
    set the rect of graphic "Background" of me to theMasterRect
end LayoutControl


setprop dgHilite pBoolean
    -- This custom property is set when the highlight of your custom template has
    -- changed. By default the "Background" graphic will be highlighted for you. 
    -- You only add script here if you want to further customize the highlight.
    
    -- Example:
    if pBoolean then
        set the foregroundcolor of me to the dgProp["hilited text color"] of the dgControl of me
    else
        set the foregroundcolor of me to empty
    end if
end dgHilite


getprop dgDataControl
    -- Required by library so that it can locate your control.
    return the long id of me
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
                    EditFieldText the long id of the target, the dgIndex of me, theKey
                    break                 
            end switch
        end if
    end if

    pass mouseDoubleUp
end mouseDoubleUp
