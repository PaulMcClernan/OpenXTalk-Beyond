script "stack_Video_Player_button_id_1007"
-- Stack file: ide/Resources/Examples/Video Player.oxtstack
-- Object: stack "Video Player" > card (id 1002) > button "set filename" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put the long name of this stack into myLongFilename
   replace QUOTE with "" in myLongFilename
   set the itemdelimiter to slash
   if word 1 of myLongFilename is "stack" then delete word 1 of myLongFilename
   delete last item of myLongFilename
   put myLongFilename & slash & "neville-segments.mp4" into myLongFilename
   put myLongFilename
   set the filename of player "a" to myLongFilename
end mousedown
