script "stack_revPreferencesGUI_button_id_1292"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Mobile Support" (id 1254) > group "Android SDK" (id 1289) > group "Android SDK Controls" (id 1290) > button "ChooseAndroid" (id 1292)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   answer folder "Please choose the location of your Android development SDK"
   if it is not empty then
      if revIDEDeployAndroidIsValidSDK(it) then
         setAndroidSDK it
      else
         answer error "The chosen folder is not a valid Android SDK. Please ensure you have installed it correctly, and enabled support for" && revIDEDeployAndroidRequiredSDK()
      end if
   end if
end mouseUp
