script "stack_OpenXTalk_Lite_Dictionary_field_id_205261"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > field "favs" (id 205261)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   set the hilitedline of fld "tEntries" to none
   put the hilitedline of me into tLine
   if tLine is "" then put "" into cd fld "notes"
   if tLine is "" then exit mousedown
   --
   put line tLine of me into tSearchTerm
   put the favPaths of me into tFavItems
   put line tLine of tFavItems into tFilename
   if there is a file tFilename then
      -- load it
      put tFilename into cd fld "path"
      send mousedown to cd btn "load"
      send loadNotes to fld "notes"
   else
      -- file doesn't exist
      if tLine is "" then put "" into cd fld "notes"
      Answer "I can't find the file:" & return & "'" & tFilename & "'" & return &¬
      " " & return &¬
      "Should I delete this saved item?" with "Yes" or "No"
      if it is "Yes" then
         put the favPaths of cd fld "favs" into tFavPaths
         delete line tLine of tFavPaths
         set the favPaths of cd fld "favs" to tFavPaths
         delete line tLine of cd fld "favs"
         send hSaveFavs to btn "favaddbtn" -- save the changes
      end if
   end if
end mousedown
