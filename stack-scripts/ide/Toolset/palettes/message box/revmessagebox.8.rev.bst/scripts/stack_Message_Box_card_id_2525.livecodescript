script "stack_Message_Box_card_id_2525"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Global Properties" (id 2525)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   local tPropertyNames
   lock screen
   
   put revIDEGlobalProperties() into tPropertyNames
   replace comma with return in tPropertyNames
   put tPropertyNames into field "type" of this card
   set the cREVFullText of field "type" to tPropertyNames
   set the hilitedLine of field "type" to the cREVHilitedProperty of field "type"
   send "revDisplayProperties" to field "type"
   
   put empty into field "filter"
   focus field "filter"
   
   send "resizeStack" to me
   unlock screen
end preOpenCard

on closeCard
   set the cREVHilitedProperty of field "type" to the hilitedLine of field "type"
end closeCard

on resizeStack
   set the rect of group "controls" of this card to the contentRect of me
   pass resizeStack
end resizeStack

setProp cREVFieldStyle pWhich
  if pWhich is "Editable" then
    set the listBehavior of field "contents" to false
    set the lockText of field "contents" to false
  else if pWhich is "List" then
    set the listBehavior of field "contents" to true
    set the lockText of field "contents" to true
  end if
  pass cREVFieldStyle
end cREVFieldStyle
