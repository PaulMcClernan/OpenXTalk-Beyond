script "stack_OpenXTalk_Lite_Dictionary_button_id_1004"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > button "load" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   lock screen
   send tCloseSearches to this card
   put cd fld "path" into tfilename
   if there is a file tfilename then
      open file tfilename for "UTF-8" text read -- OXT-Beyond: the install may be read-only, and the entries are UTF-8 (load)
      read from file tfilename until EOF
      put it into tData
      close file tfilename
      put tData into cd fld "thetext" -- so now we have the data in our card... now comes the formatting
      send tFormatEntry to button "load random"
   end if
   unlock screen
end mousedown

