script "stack_macOS_Tools_Tester_button_id_2273"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "RevealFileInFinder" (id 2273)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


ON mouseUp pMouseButton
   answer "This should reveal and select this stack file in the Finder without using any AppleScript or JSX"
   -- get RevealFileInFinder(the filename of this stack)
   RevealFileInFinder (the filename of this stack)
   answer file "Select another file to reveal..."
   IF it is not empty then
      put it into tPath
      get RevealFileInFinder(tPath)
      IF IT = FALSE THEN
         answer "Error Occured"
      END IF
   END IF -- it is not empty
end mouseUp
