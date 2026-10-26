script "stack_CustomScriptCol_field_id_1006"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "CustomScriptCol" > card (id 1002) > field "iHateArrays" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local tLine

on mousedown
   put word 2 of the clickLine into tLine
   clickMe(tLine)
end mousedown

on clickMe tLine
   local tClickedText
   local mySECols
   local tColValue
   set the Hilitedline of field "iHateArrays" to tLine
   put line tLine of me into tClickedText
   put the textColor of line tLine of me into tColValue
   set the itemdelimiter to ","
   
   if isNumber(item 1 of tColValue) then
      put tColValue into field "rgbValue"
      try
         set the backgroundColor of graphic "cSwatch" to tColValue
         set the cClickedPart of graphic "cSwatch" to tLine
      catch e
      end try
   else
      put "error" into field "rgbValue"
      exit clickMe
   end if
end clickMe
