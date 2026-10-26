script "stack_Quick_Start_button_id_1053"
-- Stack file: ide/Resources/Examples/Quick Start.oxtstack
-- Object: stack "Quick Start" > card "Background Group" (id 1043) > button "Narrator" (id 1053)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--lesson 1: 5:30, voice: microsoft david
on mouseUp  --speak text one line at a time
   local tLesson, tLine
   if shiftKey() = "down" then  --edit fld
      set the visible of fld "Lesson" to not the visible of fld "Lesson"  --toggle show/hide
      exit to top
   end if
   put fld "Lesson" into tLesson
   put the cLine of me into tLine  --custom prop for line count
   revSetSpeechSpeed "165"  --1-300, 150=slow, 180=fast
   revSpeak line tLine of tLesson  --custom prop for line count
   if tLine >= number(lines in tLesson) then set the cLine of me to "1"  --start over
   else set the cLine of me to tLine + 1  --next line/paragraph
end mouseUp
