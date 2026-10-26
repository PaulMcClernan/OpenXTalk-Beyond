script "stack_revOnline_field_id_31872"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > field "description" (id 31872)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openField
   --if the text of me is "<Place a title for your code snippet here>" then
   --put empty into me
   --end if
   send "selectText" to me in 0 milliseconds
end openField

command selectText
   if the text of me is "<Place a description of your code snippet here>" or \
          the text of me is "<Place a description of your stack here>" or \
          the text of me is "<Place a description of your external here>" then
      select the text of me
   end if
end selectText

on exitField
   if the text of me is empty then
      if the cType of the owner of me is "code snippet" then
         put "<Place a description of your code snippet here>" into me
      else if the cType of the owner of me is "external" then
         put "<Place a description of your external here>" into me
      else
         put "<Place a description of your stack here>" into me
      end if
   end if
end exitField

on closeField
   if the text of me is empty then
      if the cType of the owner of me is "code snippet" then
         put "<Place a description of your code snippet here>" into me
      else if the cType of the owner of me is "external" then
         put "<Place a description of your external here>" into me
      else
         put "<Place a description of your stack here>" into me
      end if
   end if
end closeField
