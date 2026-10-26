script "stack_Data_Grid_Templates_2026101801_button_id_1084"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > substack "Data Grid Templates 2026101801" > card (id 1022) > button "Country Behavior" (id 1084)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- This script defines the behavior of a table column's custom template.

on FillInData pData
   -- This message is sent when the Data Grid needs to populate
   -- this template with the column data. pData is the value to be displayed.

   -- Example:

   set the icon of button 1 of me to (pData & ".png")
   set the tooltip of button 1 of me to pData
end FillInData


on LayoutControl
   local theMasterRect

   -- This message is sent when you should layout your template's controls if your template is a group.
   -- If your template is not a group then there is no work to do here.
   -- The first thing you should do is capture 'the rect of me'.
   -- You can use items 1 through 4 of the rect as boundaries for laying out your controls.

   -- Example:
   put the rect of me into theMasterRect

   set the rect of button 1 of me to theMasterRect
end LayoutControl


setprop dgHilite pBoolean
   -- This custom property is set when the highlight of your column template has
   -- changed. You only add script here if you want to customize the highlight.

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
   -- Example of how to edit the contents of a field (assuming the column template this is
   -- associated with is a field).
   -- By passing the index of the record linked to the copy of this template and the name of the
   -- column being edited the data grid will automatically save the changes the user
   -- makes and refresh the UI by calling FillInData and resizeControl.
   if pMouseBtnNum is 1 then
      if word 1 of the target is "field" then
         ## word 1 to -2 because of unique numbers (i.e. 0001, 0002) that the data grid adds to each
         ## copy of this template that is made.
         if the dgProps["allow editing"] of the dgControl of me then
            EditFieldText the long id of the target, the dgIndex of me, word 1 to -2 of the short name of me
         end if
      end if
   end if

   pass mouseDoubleUp
end mouseDoubleUp
