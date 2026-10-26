script "stack_revPreferencesGUI_button_id_1156"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Colorization Scheme" (id 1156)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   lock screen
   close stack "CustomScriptCol"
   if pItemName is "Default" then
      put "255,255,255" into tCustColor
   end if
   if pItemName is "Dark Mode" then
      put "51,51,51" into tCustColor
   end if
   if pItemName is "Revolution classic" then
      put "230,230,230" into tCustColor
   end if
   if pItemName is "vibrant" then
      put "0,0,0" into tCustColor
   end if
   if pItemName is "oxt lite light" then
      put "242,242,242" into tCustColor -- tperry 22-4-24
   end if
   if pItemName is "oxt lite dark" then
      put "40,40,40" into tCustColor -- tperry 20-4-24
   end if
   if pItemName is "Custom" then
      doCustomPopup
   end if
   
   
   revIDESetPreference "cScriptEditor," & "colorization,scheme", pItemName
   set the cColor of button "Background Color" of card "Script Editor" of stack "revPreferencesGUI" to tCustColor
   set the cColor of button "Debug Background Color" of card "Script Editor" of stack "revPreferencesGUI" to tCustColor
   
   revIDESetPreference "cScriptEditor," & "editor,backgroundcolor", tCustColor
   revIDESetPreference "cScriptEditor," & "editor,debugBackgroundcolor", tCustColor
   updateSwatches
   updateOpenScriptEditors
   unlock screen
end menuPick

on doCustomPopup
   set the hasFired of card 1 of stack "CustomScriptCol" to false
   open stack "CustomScriptCol"
   send mousedown to button "update" of stack "CustomScriptCol" in 40 milliseconds
   
end doCustomPopup
