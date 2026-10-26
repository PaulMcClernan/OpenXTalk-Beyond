script "stack_RSS_Reader_field_id_1184"
-- Stack file: ide/Resources/Examples/Remastered/RSS Reader.oxtstack
-- Object: stack "RSS Reader" > card "Reader" (id 1032) > group "List" (id 1181) > field "Stories" (id 1184)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --a click on a story shows it
   local tLine
   put word 2 of the clickLine into tLine
   if tLine is an integer then
      showStory (tLine + 1) div 2  --each story is two lines: its title, and when it came
   end if
end mouseUp
