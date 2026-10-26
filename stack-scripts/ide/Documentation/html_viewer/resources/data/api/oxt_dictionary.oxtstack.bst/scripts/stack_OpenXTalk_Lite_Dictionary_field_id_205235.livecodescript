script "stack_OpenXTalk_Lite_Dictionary_field_id_205235"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > field "tDropSearches" (id 205235)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local tThisMyLine
on mousedown
   lock screen
   put the hilitedLine of me into tLine
   put the tFoundLines of me into tAbsoluteLineNumbers
   put line tLine of tAbsoluteLineNumbers into tThisMyLine
   send tCloseSearches to this card
   --
   send hRestoreSelection to me
   unlock screen
   
   send mousedown to fld "tEntries"
   send hRestoreSelection to me in 10 ticks
   
end mousedown


on hRestoreSelection
   set the hilitedline of cd fld "tEntries" to tThisMyLine -- restore selection of line
end hRestoreSelection
