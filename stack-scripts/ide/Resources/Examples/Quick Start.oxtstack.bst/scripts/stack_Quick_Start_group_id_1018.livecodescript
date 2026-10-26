script "stack_Quick_Start_group_id_1018"
-- Stack file: ide/Resources/Examples/Quick Start.oxtstack
-- Object: stack "Quick Start" > card "Buttons & Fields" (id 1013) > group "Colors" (id 1018)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --radio buttons group
   set the backColor of fld "Field Test" to the hilitedButtonName of me  --name of selected button
end mouseUp
