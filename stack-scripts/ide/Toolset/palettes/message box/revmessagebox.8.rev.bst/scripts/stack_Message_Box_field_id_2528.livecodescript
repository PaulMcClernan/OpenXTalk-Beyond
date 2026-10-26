script "stack_Message_Box_field_id_2528"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Global Properties" (id 2525) > group "controls" (id 2535) > field "filter" (id 2528)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command revFilter
   local tSelectedLine, tText
   put line (the hilitedLine of field "type") of field "type" into tSelectedLine
   put the cREVFullText of field "type" into tText
   filter tText with ("*" & the text of me & "*")
   put tText into field "type"
   set the wholeMatches to true
   set the hilitedLine of field "type" to lineOffset(tSelectedLine, tText)
   send "revDisplayProperties" to field "type"
end revFilter

on rawKeyUp
   revFilter
   pass rawKeyUp
end rawKeyUp
