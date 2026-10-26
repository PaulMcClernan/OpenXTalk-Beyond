script "stack_Data_Grid_Templates_2026101802_button_id_1012"
-- Stack file: ide/Resources/Examples/Remastered/Data Grid Tables.oxtstack
-- Object: stack "Data Grid Tables" > substack "Data Grid Templates 2026101802" > card (id 1005) > button "Num Behavior" (id 1012)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- This script defines the behavior of a table column's custom template.

on FillInData pData
   set the text of fld 1 of me to pData
   set the textAlign of fld 1 of me to the dgColumnAlignment["Num"] of grp "DataGrid 1"  --col align bug fix
   if pData >= "3" then set the textColor of fld 1 of me to "Red"  --dg table conditional text color
   else set the textColor of fld 1 of me to empty  --default black
end FillInData


on LayoutControl pControlRect
   -- This message is sent when you should layout your template's controls if your template is a group.
   -- If your template is not a group then there is no work to do here.
   -- You can use items 1 through 4 of pControlRect as boundaries for laying out your controls.

   -- Example:
   set the rect of field 1 of me to pControlRect
end LayoutControl


on ResetData
   -- Sent when column data is being emptied because the control is no longer being used to display data
   set the text of field 1 of me to empty
end ResetData


on PreFillInData
   -- Sent right before new data is going to replace existing data in the column
end PreFillInData


setprop dgHilite pBoolean
   -- This custom property is set when the highlight of your column template has
   -- changed. You only add script here if you want to customize the highlight.

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


-- Data grid will call EditValue if a user action asks to edit cell content.
command EditValue
   if there is a field 1 of me then
      EditFieldText the long ID of field 1 of me, the dgIndex of me, the dgColumn of me
   end if
end EditValue


on mouseDoubleUp pMouseBtnNum
   -- Example of how to edit the contents of a field (assuming the column template this is
   -- associated with is a field).
   -- By passing the index of the record linked to the copy of this template and the name of the
   -- column being edited the data grid will automatically save the changes the user
   -- makes and refresh the UI by calling FillInData and resizeControl.
   if pMouseBtnNum is 1 then
      if word 1 of the target is "field" then
         ## word 1 to -2 because of unique numbers (i.e. 0001, 0002) that the data grid adds to each
         ## copy of this template that is made.
         if the dgProps["allow editing"] of the dgControl of me \
               and the dgColumnIsEditable[the dgColumn of me] of the dgControl of me then
            EditCellOfIndex the dgColumn of me, the dgIndex of me
            exit mouseDoubleUp
         end if
      end if
   end if

   pass mouseDoubleUp
end mouseDoubleUp
