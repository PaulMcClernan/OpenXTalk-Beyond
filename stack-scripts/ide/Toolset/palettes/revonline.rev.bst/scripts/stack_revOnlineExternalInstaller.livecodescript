script "stack_revOnlineExternalInstaller"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > substack "revOnlineExternalInstaller"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# Parameters
#   pName : the name of the external to be installed
#   pAuthorFirstname : the author's first name
#   pAuthorLastname : the author's last name
#   pAuthorWebsite : the author's web address
#   pDescription : the external's description
#   pImageData : image data for the external's icon, in Revolution format, i.e the text of an image.
#   pZipData : an array containing the zip archive data for the external files, this has at least one of the following keys:
#      "windows" - zip archive containing the windows DLL and any other supporting files / folders
#      "linux" - zip archive containing the linux SO and any other supporting files / folders
#      "osx" - zip archive containing the OS X bundle and any other supporting materials.
# Description
#   Creates and sets up a new installer for the external specified by the parameters. Returns the long id of the resulting stack
--command createInstaller pName, pAuthorFirstname, pAuthorLastname, pAuthorWebsite, pDescription, pImageData, pZipData
###command createInstaller pName, pAuthorName, pDescription, pImageData, pZipData
   --checkInput pName, pAuthorFirstname, pAuthorLastname, pAuthorWebsite, pDescription, pImageData, pZipData
   --if the result is not empty then
      --return the result
   --end if
   
command createInstaller pPaths, pDescription, pName, pAuthor, pImageData
   local tInstaller, tZipData
   put createInstallerStack() into tInstaller
   repeat for each key tKey in pPaths
      put getArchiveData(pPaths[tKey]) into tZipData[tKey]
   end repeat
   setupTextFields tInstaller, pName, pAuthor, pDescription
   setupImage tInstaller, pImageData
   setupProperties tInstaller, tZipData
   return tInstaller
end createInstaller

private command checkInput pName, pAuthorFirstname, pAuthorLastname, pAuthorWebsite, pDescription, pImageData, pZipData
   if pName is empty then
      return "name must be non-empty"
   end if
   
   if pZipData["windows"] is empty and pZipData["osx"] is empty and pZipData["linux"] is empty then
      return "The external must support at least one platform"
   end if
   
   return empty
end checkInput

private function createInstallerStack
   clone invisible stack "revonlineExternalTemplate"
   return the long id of it
end createInstallerStack

private command setupTextFields pInstaller, pName, pAuthorName, pDescription
   set the text of field "Name" of pInstaller to "Name:" & tab & tab & pName
   set the text of field "Author" of pInstaller to "Author:" & tab & tab & pAuthorName
   put "Description:" & return into field "description" of pInstaller
   if pDescription is not "<Place a description of your code snippet here>" then
      put pDescription after field "description" of pInstaller
      set the cValue of field "Description" of pInstaller to pDescription
   end if
   set the text of field "Date" of pInstaller to "Date:" & tab & tab & the date
   set the cValue of field "Name" of pInstaller to pName
   set the cValue of field "Author" of pInstaller to pAuthorName    
end setupTextFields

private command setupImage pInstaller, pImageData
   set the text of image "icon" of pInstaller to pImageData
   --put pImageData into image "Icon" of pInstaller
end setupImage

private command setupProperties pInstaller, pZipData
   set the cWindows of pInstaller to pZipdata["windows"]
   set the cLinux of pInstaller to pZipData["linux"]
   set the cOSX of pInstaller to pZipData["osx"]
end setupProperties

private function getArchiveData pPath
   set the itemDelimiter to slash
   local tArchive
   put the tempName into tArchive
   revZipOpenArchive tArchive, "write"
   
   if there is a folder pPath then
      # Recurse into the folder and add all files.
      addFolderToArchive item 1 to -2 of pPath, item -1 of pPath, tArchive
   else
      # In the case of Windows and Linux, the external will be (for now at least) a single file. We just add this to the archive.
      revZipAddItemWithFile tArchive, item -1 of pPath, pPath
   end if
   revZipCloseArchive tArchive
   return url ("binfile:" & tArchive)
end getArchiveData

command createCodeInstaller pCode, pDescription, pName, pAuthor, pImageData
   local tStackId
   clone invisible stack "revonlineCodeSnippetTemplate"
   put the long id of it into tStackId
   
   if pName is not "<Place a title for your code snippet here>" then
      put "Name:" & tab & tab & pName into field "Name" of tStackId
   end if
   
   put "Author:" & tab & tab & pAuthor into field "Author" of tStackId
   
   put "Description:" & return into field "description" of tStackId
   if pDescription is not "<Place a description of your code snippet here>" then
      put pDescription after field "description" of tStackId   
   end if
   
   put "Date:" & tab & tab & the date into field "date" of tStackId   
   
   set the text of image "icon" of tStackId to pImageData
   
   # Indent formatting
   local tCodeFormatted
   send "revSEFormat pCode" to revScriptEditorMain()
   put the result into tCodeFormatted   
   put tCodeFormatted into field "code" of tStackId
   # Now colorize
   local tCodeFieldId
   put the long id of field "code" of tStackId into tCodeFieldId
   local tNumberOfChars
   put the number of chars in tCodeFormatted into tNumberOfChars
   send "revSEColorizeField tCodeFieldId, 1, tNumberOfChars" to revScriptEditorMain()  
   
   return tStackId
end createCodeInstaller

private command addFolderToArchive pBaseFolder, pFolder, pArchive
   local tOldFolder
   put the defaultFolder into tOldFolder
   set the directory to pBaseFolder & slash & pFolder
   
   # First add the files, then recusively add any sub folders
   local tFiles
   put the files into tFiles
   filter tFiles without "."
   filter tFiles without ".."
   
   # Note that no error checking is bothered with here as its a test stack, the result should always be checked after any revZip operation in a real app.
   repeat for each line tFile in tFiles
      revZipAddItemWithFile pArchive, (pFolder & slash & tFile), (pBaseFolder & slash & pFolder & slash & tFile)
   end repeat
   
   # If there are no files we must still add the empty folder. This is important in particular because of OS X lproj folders
   # We do this by adding a dummy file into the folder which will be ignored by the installer.
   if the number of lines of tFiles = 0 then
      local tEmpty
      put empty into tEmpty
      revZipAddItemWithData pArchive, (pFolder & "/.ignore"), "tEmpty"
   end if
   
   local tFolders
   put the folders into tFolders
   filter tFolders without "."
   filter tFolders without ".."
   
   repeat for each line tFolder in tFolders
      addFolderToArchive pBaseFolder, (pFolder & slash & tFolder), pArchive
   end repeat
   
   set the defaultFolder to tOldFolder
end addFolderToArchive


