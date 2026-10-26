script "stack_Zip_Build_Demo_button_id_1007"
-- Stack file: ide/Resources/Examples/Zip Build Demo.oxtstack
-- Object: stack "Zip Build Demo" > card "Main" (id 1002) > button "Clear" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  -- Clear the files list and show the instruction label
  put empty into field "Files"
  labelShow
end mouseUp
