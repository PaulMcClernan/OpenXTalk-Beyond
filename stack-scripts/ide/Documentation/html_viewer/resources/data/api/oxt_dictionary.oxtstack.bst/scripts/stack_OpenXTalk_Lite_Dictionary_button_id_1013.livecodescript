script "stack_OpenXTalk_Lite_Dictionary_button_id_1013"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > button "searchBtn" (id 1013)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   -- going to do the search a bit differently from normal, as I want to keep the line offset positions
   lock screen
   put cd fld "searchFld" into tSearchString
   put the DICT_xTalk_Searchable of fld "tEntries" into tSearchData
   put tSearchData into tVisSearch
   put tSearchData into tLineSearch
   filter tVisSearch without empty
   filter lines of tVisSearch with "*" & tSearchString & "*"
   put 0 into tcount
   set the itemdelimiter to " "
   repeat the number of lines of tVisSearch
      add 1 to tcount
      put lineOffset(tSearchString, tLineSearch) into tFoundOnLine
      put tFoundOnLine into line tcount of tLineNumbers
      put "" into line tFoundOnLine of tLineSearch -- nullify it so we don't find it again
      if the last item of line tCount of tVisSearch contains ".txt" then delete last item of line tcount of tVisSearch
   end repeat  
   if the number of lines in tVisSearch >0 then
      set the itemdelimiter to ","
      put tVisSearch into fld "tDropSearches"
      set the itemdelimiter to " "
      set the tFoundLines of fld "tDropSearches" to tLineNumbers  -- contains each line a match was found on
      set the height of fld "tDropSearches" to (the textheight of fld "tDropSearches" * the number of lines in tVisSearch) + the margins of fld "tDropSearches" +4
      if the height of fld "tDropSearches" > (the height of this card - the bottom of fld "searchFld") then set the height of fld "tDropSearches" to (the height of this card - the bottom of fld "searchFld")  -- fix for search result field being too tall
      set the topleft of fld "tDropSearches" to the bottomLeft of fld "searchFld"
      show fld "tDropSearches"
   else
      -- we don't do anything
   end if
   unlock screen
   set the itemdelimiter to ","
   
end mouseup
