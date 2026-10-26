script "stack_OpenXTalk_Lite_Dictionary_button_id_205271"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > button "favaddbtn" (id 205271)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   put the dictFavFile of cd fld "favs" into tfilename
   if there is a file tfilename then
      -- carry on
      put the favPaths of cd fld "favs" into tFavPaths
      put cd fld "path" into tCurrentPath
      if tFavPaths contains tCurrentPath then
         -- already added, remove from favs
         put 0 into tcount
         repeat the number of lines in tFavPaths
            add 1 to tcount
            if line tcount of tFavPaths contains tCurrentPath then exit repeat
         end repeat
         delete line tcount of tFavPaths
         set the favPaths of cd fld "favs" to tFavPaths
         delete line tcount of cd fld "favs"
         if the hilitedLine of cd fld "favs" is "" then put "" into cd fld "notes"
         hSaveFavs -- save the changes
      else
         -- not yet added, continue
         put the number of lines of tFavPaths +1 into tLine
         put tCurrentPath into line tLine of tFavPaths
         filter lines of tFavPaths without empty
         set the favPaths of cd fld "favs" to tFavPaths
         put line 1 of cd fld "styledTextField" into tFavItemName
         put tFavItemName into line tLine of cd fld "favs"
         filter lines of cd fld "favs" without empty
         hSaveFavs -- save the changes
      end if
   end if
end mouseup

on hSaveFavs
   -- save changes to the favs
   put cd fld "favs" into tFavData
   put the favPaths of cd fld "favs" into tFavPaths
   put the dictFavFile of cd fld "favs" into tfilename
   delete file tfilename
   open file tfilename
   write tFavData to file tfilename
   close file tfilename
   -- and now the paths
   put the favPaths of cd fld "favs" into tPathData
   put the dictFavPathFile of cd fld "favs" into tfilename
   delete file tfilename
   open file tfilename
   write tPathData to file tfilename
   close file tfilename
end hSaveFavs
