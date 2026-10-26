script "stack_RSS_Reader_group_id_1140"
-- Stack file: ide/Resources/Examples/Remastered/RSS Reader.oxtstack
-- Object: stack "RSS Reader" > card "Reader" (id 1032) > group "Feeds" (id 1140)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --a feed's button: its address is its custom property cURL
   local tButton
   put the long id of the target into tButton
   if the cURL of tButton is empty then
      put the long owner of the target into tButton  --(the click was on the button's label or icon)
   end if
   if the cURL of tButton is not empty then
      readFeed the cURL of tButton
   end if
end mouseUp
