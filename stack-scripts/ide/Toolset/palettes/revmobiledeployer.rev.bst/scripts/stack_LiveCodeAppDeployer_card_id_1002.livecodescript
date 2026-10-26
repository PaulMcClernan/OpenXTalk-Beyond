script "stack_LiveCodeAppDeployer_card_id_1002"
-- Stack file: ide/Toolset/palettes/revmobiledeployer.rev
-- Object: stack "LiveCodeAppDeployer" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- The stack has the following custom properties containing the components
-- needed for building the app:
--     uAppName - the name of the application
--     uAppId - the (bundle) id of the application
--     uAppTimestamp - the date / time the deployer was built
--     uAppStoreEntitlements - Entitlements.xcent file for store profiles
--     uAppEntitlements - Entitlements.xcent file for developer profiles
--     uAppExecutables - List of binaries that need to be signed separately
--
-- Both the entitlements files have the 'appid' potion unset, this is replaced
-- by that from the profile.
--
-- Then, next to the executable there will be a 'payload' file which is simply
-- a zip of the built standalone to be signed.

local sProperties

local sProfiles
local sCurrentProfile

on preOpenCard
   put empty into sProfiles
   put empty into sCurrentProfile
   
   put the arrayDecode of the decompress of url ("binfile:" & computePropertiesPath()) into sProperties
   
   set the text of field "Name" to sProperties["name"]
   set the text of field "Id" to sProperties["id"]
   set the text of field "Timestamp" to sProperties["timestamp"]
   
   updateInterface
end preOpenCard

-- Whenever the app is resumed, update profiles
on resume
   updateInterface
end resume

-- The user has changed choice of profile
on currentProfileChanged
   repeat for each key tProfile in sProfiles
      if the menuHistory of button "Profile" is sProfiles[tProfile]["index"] then
         put tProfile into sCurrentProfile
         exit repeat
      end if
   end repeat
   updateProfileChoice
end currentProfileChanged

private command updateInterface
   updateProfiles
   
   get the keys of sProfiles
   sort it by sProfiles[each]["name"]
   
   local tProfileNames
   repeat for each line tProfile in it
      put sProfiles[tProfile]["name"] & return after tProfileNames
   end repeat
   delete the last char of tProfileNames
   
   set the text of button "Profile" to tProfileNames
   
   updateProfileChoice
end updateInterface

private command updateProfileChoice
   if sCurrentProfile is not among the keys of sProfiles then
      set the label of button "Profile" to "<choose a provisioning profile>"
      set the enabled of button "Build" to false
   else
      set the menuHistory of button "Profile" to sProfiles[sCurrentProfile]["index"]
      set the enabled of button "Build" to true
   end if
end updateProfileChoice

private command updateProfiles
   local tOldFolder
   put the folder into tOldFolder
   
   put empty into sProfiles
   
   set the folder to "~/Library/MobileDevice/Provisioning Profiles"
   if the result is not empty then
      exit updateProfiles
   end if
   
   local tProfileFiles
   put the files into tProfileFiles
   filter tProfileFiles with "*.mobileprovision"
   
   repeat for each line tProfile in tProfileFiles
      local tContents, tAppId, tIsDist, tName, tId
      put url ("file:" & tProfile) into tContents
      
      set the itemDelimiter to "."
      put item 1 of tProfile into tId
      set the itemDelimiter to comma
      
      get lineOffset("<key>DeveloperCertificates</key>", tContents)
      if it is 0 then
         next repeat
      end if
      get line it + 3 to it + (lineOffset("</data>", tContents, it) - 1) of tContents
      put the base64Decode of it contains "Distribution" into tIsDist
      
      get lineOffset("<key>ApplicationIdentifierPrefix</key>", tContents)
      if it is 0 then
         next repeat
      end if
      get word 1 to -1 of line it + 2 of tContents
      get char 9 to -10 of it
      put it into tAppId
      
      get lineOffset("<key>Name</key>", tContents)
      if it is 0 then
         next repeat
      end if
      get word 1 to -1 of line it + 1 of tContents
      put char 9 to -10 of it into tName
      
      put tId into sProfiles[tId]["id"]
      put tName into sProfiles[tId]["name"]
      put tAppId into sProfiles[tId]["appid"]
      put tIsDist into sProfiles[tId]["store"]
   end repeat
   
   local tIndex
   get the keys of sProfiles
   sort it by sProfiles[each]["name"]
   repeat for each line tLine in it
      add 1 to tIndex
      put tIndex into sProfiles[tLine]["index"]
   end repeat
   
   set the folder to tOldFolder
end updateProfiles

private command buildApp pProfile, pAppBundle
   -- Make the output app bundle folder
   create folder pOutput
   if the result is not empty or there is no folder pAppBundle then
      throw "unable to create app bundle folder"
   end if
   
   -- Unzip the payload
   get shell("unzip -qq" && quote & computePayloadPath() & quote && "-d" && quote & pAppBundle & quote)
   if it is not empty then
      throw "unable to unzip partially built app"
   end if
   
   -- Copy the chosen profile
   put url ("binfile:~/Library/MobileDevice/Provisioning Profiles/" & pProfile & ".mobileprovision") into \
         url ("binfile:" & pAppBundle & slash & "embedded.mobileprovision")
   if the result is not empty then
      throw "unable to copy provisioning profile"
   end if
   
   local tCertificate, tEntitlements, tProfileInfo
   put sProfiles[pProfile] into tProfileInfo
   
   -- Determine what kind of profile is being used
   if tProfileInfo["store"] then
      put sProperties["store_entitlements"] into tEntitlements
      put "iPhone Distribution" into tCertificate
   else
      put sProperties["entitlements"] into tEntitlements
      put "iPhone Developer" into tCertificate
   end if
   
   -- Construct the entitlements file
   replace "${APP_IDENTIFIER}" with tProfileInfo["appid"] in tEntitlements
   replace "${BUNDLE_IDENTIFIER}" with sProperties["id"] in tEntitlements
   put numToChar(0xfa) & numToChar(0xde) & numToChar(0x71) & numToChar(0x71) & binaryEncode("M", the length of tEntitlements + 8) before tEntitlements
   
   local tEntitlementsFile
   put tempName() into tEntitlementsFile
   put tEntitlements into url ("binfile:" & tEntitlementsFile)
   
   -- Change the current folder temporarily to the engine path
   local tOldFolder
   put the folder into tOldFolder
   set the folder to computeEnginePath()
   put "codesign_allocate" into $CODESIGN_ALLOCATE
   
   -- Codesign each extra executable
   repeat for each line tExecutable in the sProperties["name"] of this stack
      get shell("codesign --verbose -f -s" && quote & tCertificate & quote && \
            "--entitlements" && quote & tEntitlementsFile & quote && \
            quote & pAppBundle & slash & tExecutable & quote)
   end repeat
   
   -- Perform the codesigning
   get shell("codesign --verbose -f -s" && quote & tCertificate & quote && \
         "--resource-rules=" & quote & pAppBundle & slash & "ResourceRules.plist" & quote && \
         "--entitlements" && quote & tEntitlementsFile & quote && \
         quote & pAppBundle & quote)
   
   -- Reset the folder
   set the folder to tOldFolder
   
   -- Delete the temporary file
   delete file tEntitlementsFile
   
   if not (it contains "signed bundle") then
      throw "codesigning failed with" && it
   end if
end buildApp

private function computeEnginePath
   set the itemDelimiter to slash
   return the item 1 to -2 of the effective filename of this stack
end computeEnginePath

private function computePropertiesPath
   return computeEnginePath() & slash & "properties"
end computePropertiesPath

private function computePayloadPath
   return computeEnginePath() & slash & "payload"
end computePayloadPath
