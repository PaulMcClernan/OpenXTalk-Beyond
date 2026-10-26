script "stack_revStandaloneSettings_button_id_2263"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Requirements and Restrictions" (id 2255) > button "Minimum Android Version" (id 2263)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   // SN-2015-05-13: [[ AndroidVersions ]] Make the Android versions
   //  something changeable from script-only stacks
   storeSetting "minimum version", revIDEDeployAndroidApiFromVersion(pItemName)
end menuPick

on updateSettings pAPI
   local tVersionsList
   
   // SN-2015-05-13: [[ AndroidVersions ]] Dynamically generate the list
   //  of Android versions
   put revIDEDeployAndroidGetVersionsList() into tVersionsList
   replace comma with LF in tVersionsList
   set the text of me to tVersionsList
   
   local tAPIsList
   local tMenuHistory
   put revIDEDeployAndroidGetAPIsList() into tAPIsList
   
   if pAPI < item 1 of tAPIsList then
      menuPick line 1 of the text of me
      put 1 into tMenuHistory
   else if pApi > last item of tAPIsList then
      menuPick last line of the text of me
      put the number of lines in the text of me into tMenuHistory
   else
      put 1 into tMenuHistory
      repeat for each item tAndroidAPI in tAPIsList
         if tAndroidAPI is pAPI then
            exit repeat
         else
            add 1 to tMenuHistory
         end if
      end repeat
   end if   
   
   set the menuhistory of me to tMenuHistory
end updateSettings
