script "stack_Quick_Start_Guide_button_id_1207"
-- Stack file: ide/Resources/Examples/Remastered/Quick Start Guide.oxtstack
-- Object: stack "Quick Start Guide" > card "Dictionary & User Guide" (id 1035) > button "If-Then-Else" (id 1207)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --if-then-else conditional structure
   answer info "What is the weather like today?" with "Cancel" or "Rainy" or "Cloudy" or "Sunny" titled "Weather"
   if it = "Cancel" then exit to top
   if it = "Rainy" then
      put the abbrev date &cr& "Weather Forecast" &cr& it into fld "Forecast"
   else if it = "Cloudy" then
      put the short date &cr& "Today's Weather" &cr& it into fld "Forecast"
   else if it = "Sunny" then
      put the long date &cr& "Today will be:" &cr& it into fld "Forecast"
   end if
   show fld "Forecast"
end mouseUp
