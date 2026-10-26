script "stack_Quick_Start_Guide_group_id_1190"
-- Stack file: ide/Resources/Examples/Remastered/Quick Start Guide.oxtstack
-- Object: stack "Quick Start Guide" > card "Buttons & Fields" (id 1032) > group "Colors" (id 1190)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --radio buttons group
   set the backColor of fld "Field Test" to the hilitedButtonName of me  --name of selected button
   --(remaster) and its text, in the color that reads best on that one
   if the hilitedButtonName of me is "Blue" then set the textColor of fld "Field Test" to "white"
   else set the textColor of fld "Field Test" to "black"
end mouseUp
