script "stack_Data_Grid_Templates_1455622307803_button_id_1009"
-- Stack file: ide/Toolset/palettes/start center/revStartCenter.livecode
-- Object: stack "revStartCenter" > substack "Data Grid Templates 1455622307803" > card (id 1005) > button "Behavior Script" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- This script defines the behavior of your data grid's custom template. This behavior
-- only applies to 'forms' and not 'tables'.
on FillInData pDataArray   
   -- Example:
   set the text of field "stackLabel" of me to pDataArray["label"]
   set the text of field "stackPath" of me to pDataArray["filename"]
   
   set the iconPresetName of widget "icon" of me to "lc-filetype-lc-filled"
   set the foregroundColor of widget "icon" of me to uiColor("edition")
end FillInData


on LayoutControl pControlRect
   local theFieldRect
   
   -- Example:
   set the rect of graphic "background" of me to pControlRect
   set the textColor of field "stackPath" of me to uiColor("mid grey")
   set the backgroundColor of graphic "background" of me to uiColor("recentFilesBackground")
   
   if the formattedWidth of field "stackLabel" of me > the width of field "stackLabel" of me then
      truncateText the long id of field "stackLabel" of me
   end if
   
   if the formattedWidth of field "stackPath" of me > the width of field "stackPath" of me then
      truncateText the long id of field "stackPath" of me
   end if
   
   set the height of field "stackPath" of me to the formattedHeight of field "stackPath" of me
   set the top of field "stackPath" of me to the bottom of field "stackLabel" of me - 6
end LayoutControl


on ResetData
   -- Sent when data is being emptied because the control is no longer being used to display data
end ResetData


on PreFillInData
   -- Sent right before new data is going to replace existing data in the control
end PreFillInData


setprop dgHilite pBoolean   
   -- Example:
   if pBoolean then
      set the foregroundColor of widget "icon" of me to 255,255,255
      set the textColor of field "stackLabel" of me to 255,255,255
      set the textColor of field "stackPath" of me to 255,255,255
      set the backgroundColor of graphic "background" of me to uiColor("edition")
   else
      set the foregroundColor of widget "icon" of me to uiColor("edition")
      set the textColor of field "stackLabel" of me to empty
      set the textColor of field "stackPath" of me to uiColor("mid grey")
      set the backgroundColor of graphic "background" of me to uiColor("recentFilesBackground")
   end if
end dgHilite


getprop dgDataControl
   -- Required by library so that it can locate your control.
   return the long ID of me
end dgDataControl


on mouseDoubleUp pMouseBtnNum
   local theKey
   pass mouseDoubleUp
end mouseDoubleUp

command truncateText pControl
   local tText
   put the text of pControl into tText
   repeat with x = (the length of tText) down to 1
      if measureText(char 1 to x of tText,pControl) + 16 < the width of pControl then
         set the text of pControl to char 1 to x-1 of tText & "..."
         exit repeat
      else
         next repeat
      end if
   end repeat
end truncateText

on mouseEnter
   if the backgroundColor of graphic "background" of me is not uiColor("edition") then
      show graphic "background" of me
      set the backgroundColor of graphic "background" of me to uiColor("recentFilesHover")
      put true into sHilited
   end if
end mouseEnter

on mouseLeave
   if not(the mouseLoc is within the rect of me) then
      if the backgroundColor of graphic "background" of me is not uiColor("edition") then
         set the backgroundColor of graphic "background" of me to uiColor("recentFilesBackground")
      end if
   end if
end mouseLeave

