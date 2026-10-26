script "stack_Message_Box_field_id_2532"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Global Properties" (id 2525) > group "controls" (id 2535) > field "contents" (id 2532)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on revSetDiscreteProperty
   if the cREVFieldStyle of this card is "List" then
      put line (the hilitedLine of field "type") of field "type" into tSelected
      put line (the hilitedLine of field "contents") of field "contents" into tProperty
      do "set the" && tSelected && "to" && quote & tProperty & quote
   end if
end revSetDiscreteProperty

on mouseUp
   revSetDiscreteProperty
   pass mouseUp
end mouseUp

on arrowKey
   send "revSetDiscreteProperty" to me in 10 milliseconds
   pass arrowKey
end arrowKey

on closeField
   put line (the hilitedLine of field "type") of field "type" into tSelected
   if the cREVFieldStyle of this card is "Editable" and tSelected is not empty
   then do "set the" && tSelected && "to field" && quote & "contents" & quote
   pass closeField
end closeField
