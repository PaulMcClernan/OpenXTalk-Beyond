script "stack_Quick_Start_Guide_button_id_1201"
-- Stack file: ide/Resources/Examples/Remastered/Quick Start Guide.oxtstack
-- Object: stack "Quick Start Guide" > card "Script Editor" (id 1034) > button "Answer Command" (id 1201)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --answer command
   answer "Please make a choice between Red or Green." with "Cancel" or "Green" or "Red" titled "Make A Choice"
   if it = "Cancel" then exit to top
   if it = "Red" then answer "You chose the Red button." with "OK" titled "Red Choice"
   else if it = "Green" then answer "Green was the button you chose." with "OK" titled "Green Choice"
end mouseUp
