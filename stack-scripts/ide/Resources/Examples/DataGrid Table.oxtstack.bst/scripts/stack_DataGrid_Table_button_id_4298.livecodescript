script "stack_DataGrid_Table_button_id_4298"
-- Stack file: ide/Resources/Examples/DataGrid Table.oxtstack
-- Object: stack "DataGrid Table" > card (id 1002) > button "Lesson Plan" (id 4298)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --lesson plan.txt
   local tPath, tPlan
   answer "Create a text file" &&quote& "Lesson Plan" &quote&& "on the desktop?" with "Cancel" or "OK" titled "Teacher Lesson Plan"
   if it = "Cancel" then exit to top
   put specialfolderPath("desktop") &"/"& "Lesson Plan.txt" into tPath  --create new
   put the cLessonPlan of me into tPlan  --custom property containing plan
   put tPlan into url ("file:" & tPath)  --export text file
   if result() <> empty then answer "Sorry, there was a problem writing to a text file." &cr& result() with "OK" titled "Error"
   else answer "Successfully exported a text file" &&quote& "Lesson Plan" &quote&& "to the desktop." with "OK" titled "Teacher Lesson Plan"
end mouseUp
