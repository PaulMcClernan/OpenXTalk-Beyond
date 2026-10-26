script "stack_revPreferencesGUI_button_id_1305"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Mobile Support" (id 1254) > group "Android SDK" (id 1289) > button "ChooseJDK" (id 1305)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   answer folder "Please choose the location of your JDK"
   if it is not empty then
      if revIDEDeployAndroidIsValidJDK(it) then
         setJDK it
      else
         answer error "The chosen folder is not a valid JDK. Please ensure you have installed it correctly."
      end if
   end if
end mouseUp
