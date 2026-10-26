script "stack_Quick_Start_field_id_1040"
-- Stack file: ide/Resources/Examples/Quick Start.oxtstack
-- Object: stack "Quick Start" > card "Orientation" (id 1002) > field "Field Test" (id 1040)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   answer "A locked field can receive a mouseUp message and act like a button." with "OK" titled "Orientation"
end mouseUp
