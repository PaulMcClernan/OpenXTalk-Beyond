script "stack_OpenXTalk_Lite_Dictionary_field_id_205265"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > field "notes" (id 205265)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseleave
   put the hilitedline of fld "favs" into tLine
   if tLine is "" then exit mouseleave
   --
   put the dictNotePath of me into tNotePath
   put the text of me into tData
   put line tLine of fld "favs" into tTerm
   put tNotePath & tTerm & ".txt" into tFilename
   delete file tFilename
   open file tFilename
   write tData to file tFilename
   close file tFilename
end mouseleave

on loadNotes
   put the dictNotePath of me into tNotePath
   put the hilitedline of fld "favs" into tLine
   put line tLine of fld "favs" into tTerm
   put tNotePath & tTerm & ".txt" into tFilename
   if there is a file tFilename then
      open file tFilename
      read from file tFilename until EOF
      put it into tData
      close file tFilename
      put tData into me
   else
      put "" into cd fld "notes"
   end if
end loadNotes
