script "stack_Zip_Extract_Demo_button_id_1009"
-- Stack file: ide/Resources/Examples/Zip Extract Demo.oxtstack
-- Object: stack "Zip Extract Demo" > card "Main" (id 1002) > button "Clear" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  -- Clear the file list and show the instruction label
  put empty into field "Files"
  labelShow
end mouseUp
