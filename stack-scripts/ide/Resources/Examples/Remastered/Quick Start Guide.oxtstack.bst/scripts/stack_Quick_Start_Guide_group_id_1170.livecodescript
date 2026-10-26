script "stack_Quick_Start_Guide_group_id_1170"
-- Stack file: ide/Resources/Examples/Remastered/Quick Start Guide.oxtstack
-- Object: stack "Quick Start Guide" > card "Orientation" (id 1031) > group "Narration" (id 1160) > group "Narrator" (id 1170)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--lesson 1: 5:30, voice: microsoft david
on mouseUp  --speak text one line at a time
   local tLesson, tLine, tError
   if shiftKey() = "down" then  --edit fld
      set the visible of fld "Lesson" to not the visible of fld "Lesson"  --toggle show/hide
      scrollThumbs  --(remaster) its thumb, shown or hidden with it: see the stack script
      exit to top
   end if
   put fld "Lesson" into tLesson
   put the cLine of me into tLine  --custom prop for line count
   narratorShow tLine  --(remaster) the words of this line, in the balloon: see the stack script
   try  --(remaster) where there is no voice, the narrator says so, and its words are there to read
      revSetSpeechSpeed "165"  --1-300, 150=slow, 180=fast
      revSpeak line tLine of tLesson  --custom prop for line count
   catch tError
      narratorNoVoice
   end try
   if tLine >= number(lines in tLesson) then set the cLine of me to "1"  --start over
   else set the cLine of me to tLine + 1  --next line/paragraph
end mouseUp
