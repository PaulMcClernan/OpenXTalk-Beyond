script "stack_Data_Grid_Tables_group_id_1117"
-- Stack file: ide/Resources/Examples/Remastered/Data Grid Tables.oxtstack
-- Object: stack "Data Grid Tables" > card "Start" (id 1002) > group "Lesson Plan" (id 1117)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --lesson plan.txt
   local tPath, tPlan
   answer "Terry Little's lesson plan, for teachers: copy it, or save it as a text file." with "Cancel" or "Copy" or "Save" titled "Teacher Lesson Plan"
   if it = "Cancel" then exit to top
   put the cLessonPlan of me into tPlan  --custom property containing plan
   if it = "Copy" then  --added: on the clipboard, to paste into a document
      set the clipboardData["text"] to tPlan
      answer "The lesson plan is on the clipboard: paste it into a document." with "OK" titled "Teacher Lesson Plan"
      exit to top
   end if
   if the platform is "HTML5" then  --added: a browser cannot save a file here
      answer "A browser cannot save a file here: choose Copy, then paste the plan into a document." with "OK" titled "Teacher Lesson Plan"
      exit to top
   end if
   --it was a file on the desktop, which a computer may not let a program write to; you say where now:
   --put specialfolderPath("desktop") &"/"& "Lesson Plan.txt" into tPath  --create new
   ask file "Save the lesson plan as:" with "Lesson Plan.txt"
   if it is empty then exit to top  --Cancel
   put it into tPath
   put tPlan into url ("file:" & tPath)  --export text file
   if result() <> empty then answer "Sorry, there was a problem writing to a text file." &cr& result() with "OK" titled "Error"
   else answer "Successfully exported a text file" &&quote& "Lesson Plan" &quote&& "to" && tPath & "." with "OK" titled "Teacher Lesson Plan"
end mouseUp
