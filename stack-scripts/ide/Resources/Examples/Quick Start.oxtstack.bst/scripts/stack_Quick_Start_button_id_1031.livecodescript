script "stack_Quick_Start_button_id_1031"
-- Stack file: ide/Resources/Examples/Quick Start.oxtstack
-- Object: stack "Quick Start" > card "Commands & Functions" (id 1015) > button "Commands & Functions" (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --display all commands or functions
   local tNames  --declare temporary container
   answer "Display all Commands or all Functions?" with "Cancel" or "Functions" or "Commands" titled "Display"
   if it = "Cancel" then exit to top  --stop executing code
   if it = "Commands" then
      put the commandNames into tNames
      put the number of lines in tNames && "Commands:" &cr& tNames into fld "Display"  --cr = carriage return
   else if it = "Functions" then
      put the functionNames into tNames
      put the number of lines in tNames && "Functions:" &cr& tNames into fld "Display"
   end if
end mouseUp
