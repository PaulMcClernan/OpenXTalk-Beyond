script "stack_macOS_Tools_Tester_button_id_1011"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "Get Frontmost Application" (id 1011)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- Sent when the mouse is released after clicking
-- pMouseButton specifies which mouse button was pressed
on mouseUp pMouseButton
   Answer "This will wait 3 seconds to allow time for the tester to switch to another apploication, otherwise the frontmost application will be the OXT-Beyond IDE"
   wait 3 seconds with messages
   --put GetFrontmostApplication("Path") -- return just the path string
   --put GetFrontmostApplication("ProcessID") -- return just the process ID number
   --put GetFrontmostApplication("BundleID") -- return just the bundle ID string
   put GetFrontmostApplication("") -- return line delimited list of all info
   AppUnhide 
   do "tell application "& quote & "OXT-Beyond" & quote & " to activate" as AppleScript
   
end mouseUp
