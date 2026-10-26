script "stack_revPreferencesGUI_card_id_1473"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Debug Properties" (id 1473)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global tDebugOut

on opencard
   set cursor to busy
   lock screen
   put "started first part: " & the milliseconds into tDebugOut
   put the customProperties of stack "revpreferences" into tProps
   put displayArrayData(tProps,".") into tDatRtrn
   filter lines of tDatRtrn with"..*"
   replace (".."&tab) with "" in tDatRtrn
   sort lines of tDatRtrn ascending
   set the text of fld "fPREFFS" to tDatRtrn
   put "done second part: " & the milliseconds into line 2 of tDebugOut
   unlock screen
   send tupdvis to cd fld "fPREFFS"  -- colourise 
end opencard

on closecard
   put "" into cd fld "fPREFFS"
   put "" into cd fld "suggestions"
   put "" into cd fld "search"
end closecard

function displayArrayData pArray, pIndent
   # create the variable that loops through the keys in the array
   local tKey
   if pArray is an array then
      # print information to indicate that we are entering a new nested level of the array
      get "Array" & return
      # print full stops that allow the reader to track the depth of an element
      put "." after pIndent
      # create the indentation
      put tab after pIndent
      repeat for each key tKey in pArray
         # call displayArrayData with a nested array
         put format("%s[%s] => %s\n", pIndent, tKey, displayArrayData (pArray[tKey], pIndent)) after it
      end repeat
      delete the last char of it
      return it
   else
      return pArray
   end if 
end displayArrayData

