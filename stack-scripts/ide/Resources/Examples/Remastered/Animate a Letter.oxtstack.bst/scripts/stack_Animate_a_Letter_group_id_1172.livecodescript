script "stack_Animate_a_Letter_group_id_1172"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Start" (id 1002) > group "LessonPlan" (id 1166) > group "Save" (id 1172)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --lesson plan.txt
   local tPath
   ask file "Save the lesson plan as:" with "Lesson Plan.txt"
   if it is empty then exit to top  --Cancel
   put it into tPath
   put the cLessonPlan of this card into url ("file:" & tPath)  --export text file, cLessonPlan is a custom property of this card
   if the result <> empty then answer "Sorry, there was a problem writing to a text file." &cr& the result with "OK" titled "Error"
   else answer "Saved the lesson plan as" && quote & tPath & quote & "." with "OK" titled "Teacher Lesson Plan"
end mouseUp
