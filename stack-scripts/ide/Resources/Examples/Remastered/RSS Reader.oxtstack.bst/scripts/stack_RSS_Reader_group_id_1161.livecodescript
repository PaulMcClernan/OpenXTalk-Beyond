script "stack_RSS_Reader_group_id_1161"
-- Stack file: ide/Resources/Examples/Remastered/RSS Reader.oxtstack
-- Object: stack "RSS Reader" > card "Reader" (id 1032) > group "Read" (id 1161)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   readFeed the text of field "URL"
end mouseUp
