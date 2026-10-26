script "stack_Play_a_Video_group_id_1125"
-- Stack file: ide/Resources/Examples/Remastered/Play a Video.oxtstack
-- Object: stack "Play a Video" > card "Three Buttons" (id 1031) > group "set filename" (id 1125)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(Remastered for OXT-Beyond, 2026: the lines marked "(2026)" are new or changed, and say why)
on mousedown
   local myLongFilename  --(2026) declared, for strict compilation
   put the long name of this stack into myLongFilename
   replace QUOTE with "" in myLongFilename
   set the itemdelimiter to slash
   if word 1 of myLongFilename is "stack" then delete word 1 of myLongFilename
   delete last item of myLongFilename
   delete last item of myLongFilename  --(2026) this stack is in Remastered, in the folder the video is in
   put myLongFilename & slash & "neville-segments.mp4" into myLongFilename
   put myLongFilename
   set the filename of player "a" to myLongFilename
   showHow myLongFilename  --(2026) the note under the player: can it play the video here?
end mousedown
