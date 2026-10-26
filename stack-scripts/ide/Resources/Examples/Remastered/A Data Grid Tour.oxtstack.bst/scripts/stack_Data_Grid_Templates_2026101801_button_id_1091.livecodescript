script "stack_Data_Grid_Templates_2026101801_button_id_1091"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > substack "Data Grid Templates 2026101801" > card (id 1087) > button "Behavior Script" (id 1091)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- This script defines the behavior of your data grid's custom template. This behavior
-- only applies to 'forms' and not 'tables'.

on FillInData pDataArray
   local tName  --(remaster) declared: strict compilation

   put pDataArray["First name"] & ", " & pDataArray["Last Name"] into tName
   put tName into field "name" of me

   put pDataArray["Email"] into field "email" of me
   put pDataArray["ecPhone"] into field "phone" of me
   put pDataArray["Employee ID"] into field "Employee ID" of me

end FillInData

on mouseDown pMouseButton
   local theDataGrid, theLineNo, theDataA  --(remaster) declared: strict compilation
   if pMouseButton is 1 then
      if the short name of the target is "arrow" then
         put the dgControl of me into theDataGrid
         put the dgLine of me into theLineNo

         put the dgDataOfLine[theLineNo] of theDataGrid into theDataA
         put not theDataA["Expanded"] into theDataA["Expanded"]
         set the dgDataOfLine[theLineNo] of theDataGrid to theDataA
      end if
   end if

   pass mouseDown
end mouseDown


on LayoutControl
   local theFieldRect,theMasterRect
   local r  --(remaster) declared: strict compilation

   -- This message is sent when you should layout your template's controls.
   -- This is where you resize the 'Background' graphic, resize fields and
   -- position objects.
   -- The first thing you should do is capture 'the rect of me'.
   -- For fixed height data grid forms you can use items 1 through 4 of the rect as
   -- boundaries for laying out your controls.
   -- For variable height data grid forms you can use items 1 through 3 of the rect as
   -- boundaries.

   put the rect of me into theMasterRect

   set the right of field "phone" of me to item 3 of theMasterRect

   put the rect of grc "Background" of me into r

   set the rect of grc "Background" of me to r
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
