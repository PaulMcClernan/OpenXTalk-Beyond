script "stack_OpenXTalk_Lite_Dictionary_field_id_1012"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > field "searchFld" (id 1012)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on textchanged
   set the hilitedline of fld "favs" to none -- turn off any fav hilited lines
   if the number of chars of me <4 then
      hide fld "tDropSearches"
      put "" into cd fld "tDropSearches"
   else
      send mouseup to btn "searchBtn"
   end if
end textchanged


on returninfield
   textchanged
   -- do nothing else
end returninfield

on enterInField
   textchanged
   -- do nothing else
end enterInField
