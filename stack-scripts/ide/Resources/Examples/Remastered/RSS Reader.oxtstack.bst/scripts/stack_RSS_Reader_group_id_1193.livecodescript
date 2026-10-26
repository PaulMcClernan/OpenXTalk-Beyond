script "stack_RSS_Reader_group_id_1193"
-- Stack file: ide/Resources/Examples/Remastered/RSS Reader.oxtstack
-- Object: stack "RSS Reader" > card "Reader" (id 1032) > group "Story" (id 1187) > group "Open" (id 1193)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --the whole story, in the browser
   local tLink
   put the cLink of me into tLink
   if tLink begins with "http://" or tLink begins with "https://" then  --(only a web page: a feed's link could be anything)
      launch url tLink
   end if
end mouseUp
