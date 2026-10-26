script "stack_com.livecode.pi.gradientramp_group_id_1012"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.gradientramp.livecode
-- Object: stack "com.livecode.pi.gradientramp" > card (id 1002) > group "template" (id 1008) > group "color" (id 1012)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeControl
   lock screen
   lock messages
   local tRect
   set the topleft of widget 1 of me to the topleft of me
   set the width of field 1 of me to 120
   set the topright of field 1 of me to the topright of me
   put the rect of me into tRect
   put item 1 of tRect + the width of widget 1 of me + 10 into item 1 of tRect
   put the left of field 1 of me into item 3 of tRect
   set the rect of scrollbar 1 of me to tRect
   unlock messages
   unlock screen
end resizeControl
