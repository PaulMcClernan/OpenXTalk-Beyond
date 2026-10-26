script "stack_revPreferencesGUI_button_id_1499"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Compatibility" (id 1015) > group "depbit" (id 1496) > button "Success" (id 1499)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   if the shiftkey is down then
      doInstructions
      exit mousedown
   end if
   if the hilite of me is true then
      answer "You should have all dependencies to play video. You can now enable the Player tool button above." with "Do it for me" or "Ok"
      if it is "Do it for me" then
         send tryEnablePlayer to button "disPlayerLin" 
      end if
   else
      doInstructions
   end if
end mousedown

on doInstructions
   answer "Install dependencies using:" & return &¬
   "sudo apt-get install libc6 libcairo2" & return &¬
   "(click this message to copy to clipboard)" with "More about GStreamer" or "More" or "Ok"
   if it is "More" then
      put specialFolderPath("Engine") & slash & "Externals" & slash & "DEPENDENCIES.txt" into myInfoFile
      open file myInfoFile
      read from file myInfoFile until EOF
      put it into tData
      close file myInfoFile
      answer tData
   end if
   if it is "More about GStreamer" then
      launch url "https://gstreamer.freedesktop.org/"
   end if
end doInstructions
