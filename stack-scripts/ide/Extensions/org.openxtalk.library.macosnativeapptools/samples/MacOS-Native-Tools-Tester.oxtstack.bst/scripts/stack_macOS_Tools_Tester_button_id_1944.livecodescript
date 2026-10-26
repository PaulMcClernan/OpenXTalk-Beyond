script "stack_macOS_Tools_Tester_button_id_1944"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "SetHFSCreator" (id 1944)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- Sent when the mouse is released after clicking
-- pMouseButton specifies which mouse button was pressed
on mouseUp pMouseButton
   Answer File "Pick"

   get SetHFSCreatorCodeOfFile(it,"WILD") 
   
end mouseUp
