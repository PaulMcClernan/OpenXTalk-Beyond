script "stack_revPreferencesGUI_button_id_1311"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Mobile Support" (id 1254) > group "iOS SDKs" (id 1261) > button "Remove entry" (id 1311)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tSDKs
   repeat for each item tSDK in the hilitedLine of field "iOS SDKs"
      if tSDKs is not empty then
         put return after tSDKs
      end if
      put line tSDK of field "iOS SDKs" after tSDKs
   end repeat
   removeIOSSDK tSDKs   
end mouseUp
