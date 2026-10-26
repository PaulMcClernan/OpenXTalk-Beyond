script "stack_Quick_Start_Guide_button_id_1196"
-- Stack file: ide/Resources/Examples/Remastered/Quick Start Guide.oxtstack
-- Object: stack "Quick Start Guide" > card "Commands & Functions" (id 1033) > button "Commands & Functions" (id 1196)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --display all commands or functions
   local tNames  --declare temporary container
   answer "Display all Commands or all Functions?" with "Cancel" or "Functions" or "Commands" titled "Display"
   if it = "Cancel" then exit to top  --stop executing code
   if it = "Commands" then
      put the commandNames into tNames
      filter tNames without "_*"  --(remaster) the engine's own names begin with "_": they are not for you
      put the number of lines in tNames && "Commands:" &cr& tNames into fld "Display"  --cr = carriage return
   else if it = "Functions" then
      put the functionNames into tNames
      filter tNames without "_*"  --(remaster) the same for functions
      put the number of lines in tNames && "Functions:" &cr& tNames into fld "Display"
   end if
end mouseUp
