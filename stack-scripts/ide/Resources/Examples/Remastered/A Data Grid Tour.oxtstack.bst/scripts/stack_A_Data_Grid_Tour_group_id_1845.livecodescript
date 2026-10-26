script "stack_A_Data_Grid_Tour_group_id_1845"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > card "Summary" (id 1039) > group "Data Grid Guide" (id 1845)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --added: opens the guide, as Help > Data Grid Guide PDF does
   local tError
   if the platform is "HTML5" then
      answer "The Data Grid Guide is a PDF in the Help menu of OXT-Beyond on a computer: a browser cannot open it from here." with "OK" titled "A Data Grid Tour"
      exit mouseUp
   end if
   try
      revIDELaunchResource "Data Grid Guide"
   catch tError
      answer "The Data Grid Guide could not be opened from here. It is in the Help menu of OXT-Beyond." with "OK" titled "A Data Grid Tour"
   end try
end mouseUp
