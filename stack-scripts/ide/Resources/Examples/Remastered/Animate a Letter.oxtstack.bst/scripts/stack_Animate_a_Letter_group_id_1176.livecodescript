script "stack_Animate_a_Letter_group_id_1176"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Start" (id 1002) > group "LessonPlan" (id 1166) > group "Copy" (id 1176)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --copy the lesson plan
   set the clipboardData["text"] to the cLessonPlan of this card  --custom property containing plan
   answer "The lesson plan is on the clipboard: paste it into a document." with "OK" titled "Teacher Lesson Plan"
end mouseUp
