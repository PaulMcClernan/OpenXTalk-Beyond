script "stack_revOnlineExternalTemplate"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > substack "revOnlineExternalTemplate"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command installTemporary
   # For the temporary install, we simply extract all the appropriate externals to a temporary folder,
   # create a wrapper stack for them, and insert the stack into the message path, making the externals
   # immediately available for testing in the IDE.
   
   local tTempFolder
   put specialFolderPath("Temporary") into tTempFolder
   if there is no folder tTempFolder then
      errorShow "The external cannot be installed in this way on your system because no temporary folder is available."
      exit installTemporary
   end if
   
   local tPlatform
   put convertPlatformToEnglish() into tPlatform
   
   local tPropname
   put "c" & tPlatform into tPropname
   if the tPropname of me is empty then
      errorShow "The external does not support your platform"
      exit installTemporary
   end if 
   
   local tArchiveData
   put the tPropname of me into tArchiveData
   
   local tResult
   extractFiles tArchiveData, tTempFolder
   if the result is not empty then
      errorShow the result
      exit installTemporary
   end if
   
   local tExternalPath
   put tTempFolder & slash & getExternalFilename(the platform) into tExternalPath
   
   # Create the stack and insert into the message path using "start using"
   # The stack will be named "revExternalWrapper<ExternalName>" with a number after it if 
   # needed to make the name unique.
   local tStackName
   put getWrapperStackName(getExternalName()) into tStackName
   reset the templateStack
   set the externals of the templateStack to tExternalPath
   create stack tStackName
   reset the templateStack
   
   start using stack tStackName
end installTemporary

command installFull
   # We have to install the externals to two separate places here, the user externals folder
   # and the user runtime folder.
   
   # First do the externals folder, this installs the external for use in the IDE, for the current edition of Revolution.
   # We extract only the external for the current platform to this location.
   local tExternalsPath
   put revEnvironmentUserExternalsPath() into tExternalsPath
   
   local tPlatform
   put convertPlatformToPropertyName() into tPlatform
   
   local tPropname
   put "c" & tPlatform into tPropname
   if the tPropname of me is empty then
      # The IDE does not really support using externals for building standalones on other platforms only, so for now
      # we just fail here. Perhaps there should be some more options for advanced users here?
      errorShow "The external does not support your platform"
      exit installFull
   end if
   
   local tResult
   installExternalToFolder the tPropname of me, tExternalsPath
   put the result into tResult
   if tResult is not empty then
      errorShow tResult
      exit installFull
   end if
   
   # Next install to the runtime folder. We simply install for all available platforms
   local tRuntimePath
   put revEnvironmentUserRuntimePath() into tRuntimePath
   
   local tArchiveData
   put the cWindows of me into tArchiveData
   if tArchiveData is not empty then
      infoShow "Installing external for Windows"
      installExternalToFolder tArchiveData, (tRuntimePath & "/Windows/x86-32/Externals")
      put the result into tResult
      if tResult is not empty then
         errorShow tResult
         exit installFull
      end if
   end if
   
   put the cOSX of me into tArchiveData
   if tArchiveData is not empty then
      infoShow "Installing external for OS X (universal binary)"
      installExternalToFolder tArchiveData, (tRuntimePath & "/Mac OS X/Universal/Externals")
      put the result into tResult
      if tResult is not empty then
         errorShow tResult
         exit installFull
      end if
   end if
   
   put the cLinux of me into tArchiveData
   if tArchiveData is not empty then
      infoShow "Installing external for Linux"
      installExternalToFolder tArchiveData, (tRuntimePath & "/Linux/x86-32/Externals")
      put the result into tResult
      if tResult is not empty then
         errorShow tResult
         exit installFull
      end if
   end if
   
   infoShow "done"
end installFull

private command installExternalToFolder pArchiveData, pFolder
   extractFiles pArchiveData, pFolder
   if the result is not empty then
      return the result
   end if
   
   # Once the files are all extracted, we need to update the "Externals.txt" file.
   local tNewLine
   put getExternalName() & comma & getExternalFilename() into tNewLine
   
   local tExternalsIndex
   put url ("file:" & pFolder & "/Externals.txt") into tExternalsIndex
   if tExternalsIndex is empty then
      put tNewLine into tExternalsIndex
   else
      put return & tNewLine after tExternalsIndex
   end if
   
   put tExternalsIndex into url ("file:" & pFolder & "/Externals.txt")
   return empty
end installExternalToFolder


# Extracts all files in the zip archive pArchiveData to pFolder.
private command extractFiles pArchiveData, pFolder
   # First we need to write pArchiveData to a file, as revZip cannot open an archive directly from memory.
   local tArchive
   put the tempName into tArchive
   
   local tResult
   put pArchiveData into url ("binfile:" & tArchive)
   put the result into tResult
   if tResult is not empty then
      return "Couldn't extract external data to temporary file"
   end if
   
   revZipOpenArchive tArchive, "read"
   put the result into tResult
   if tResult is not empty then
      return "Couldnt open external for processing"
   end if
   
   local tItems
   put revZipEnumerateItems(tArchive) into tItems
   
   # What to do if a file collision occurs, if empty it means we don't know and need to ask the user.
   local tOverwriteFiles
   
   set the itemDelimiter to slash
   repeat for each line tItem in tItems
      ensureFolder pFolder & slash & (item 1 to -2 of tItem)
      if there is a file (pFolder & slash & tItem) then
         # If the file exists already, revZipExtractItemToFile will overwrite it...
         if tOverwriteFiles is "true" then
            # Nothing needs doing, this will happen by default
         else if tOverwriteFiles is "false" then
            # Skip to the next item
            next repeat
         else
            answer question "The file " & (pFolder & slash & tItem) & " already exists, would you like to overwrite it?" with "Yes to all" or "Yes" or "No" or "No to all"
            if it is "Yes to all" then
               put true into tOverwriteFiles
            else if it is "No to all" then
               put true into tOverwriteFiles
               next repeat
            else if it is "No" then
               next repeat
            end if
         end if
      end if
      revZipExtractItemToFile tArchive, tItem, (pFolder & slash & tItem)
      put the result into tResult
      if tResult is not empty then
         return "Failed to extract file: " & tItem
      end if
   end repeat
end extractFiles 

private command ensureFolder pPath
   if pPath is empty then
      return empty
   end if
   
   if there is a folder pPath or there is a file pPath then
      return empty
   end if
   
   local tPath, tPart
   set the itemDelimiter to slash
   repeat for each item tPart in pPath
      put tPart & "/" after tPath
      if there is no folder tPath then
         create folder tPath
      end if
   end repeat
end ensureFolder

private function getWrapperStackName pExternalName
   local tName
   put "revExternalWrapper" & pExternalName into tName
   
   local tPostfix
   put empty into tPostfix
   
   repeat until there is no stack (tName & tPostfix)
      add 1 to tPostfix
   end repeat
   
   return (tName & tPostfix)
end getWrapperStackName

private function getExternalName
   return the cValue of field "Name" of card 1 of me
end getExternalName

# The filename of the external should always be the name of the external, followed
# by a platform specific extension.
private function getExternalFileName pPlatform
   return getExternalName() & "." & externalExtension(pPlatform)
end getExternalFileName

private function externalExtension pPlatform
   local tPlatform
   if pPlatform is empty then
      put the platform into tPlatform
   else
      put pPlatform into tPlatform
   end if
   
   switch tPlatform
      case "MacOS"
         return "bundle"
      break
      case "Win32"
         return "dll"
      break
      case "Unix"
         return "so"
      break
   end switch
end externalExtension

private function convertPlatformToEnglish
   switch the platform
      case "MacOS"
         return "OS X"
      break
      case "Win32"
         return "Windows"
      break
      case "Unix"
         return "Linux"
      break
   end switch
end convertPlatformToEnglish

private function convertPlatformToPropertyName
   switch the platform
       case "MacOS"
         return "OSX"
      break
      case "Win32"
         return "Windows"
      break
      case "Unix"
         return "Linux"
      break
   end switch
end convertPlatformToPropertyName

command infoShow pInfo
   put pInfo into field "Info" of me
end infoShow

command errorShow pError
   put pError into field "Info" of me
end errorShow
