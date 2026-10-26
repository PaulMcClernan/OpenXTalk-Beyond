script "stack_revPreferencesGUI_field_id_1479"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Debug Properties" (id 1473) > field "suggestions" (id 1479)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   lock screen
   set the itemdelimiter to ","
   put the mouseV into tclickedH
   put the top of cd fld "suggestions" into tFldVert
   put tclickedH - tFldVert into tabsVert
   put the textheight of cd fld "suggestions" into tLineH
   put round (tabsVert / tLineH, 0) into tline
   if tline <1 then put 1 into tline
   put line tline of cd fld "suggestions" into cd fld "search"
   --
   put cd fld "search" into tSearchPhrase
   put the textHeight of cd fld "fPREFFS" into tHeight
   put 0 into tCount
   repeat the number of lines of cd fld "fPREFFS"
      add 1 to tCount
      if line tCount of cd fld "fPREFFS" contains tSearchPhrase then exit repeat
   end repeat
   put tcount * tHeight - (the margins of cd fld "fPREFFS" /2) - tHeight into tVertScroll
   set the vScroll of cd fld "fPREFFS" to tVertScroll
   --
   hide cd fld "suggestions"
   unlock screen
   select text of cd fld "search"
end mousedown
