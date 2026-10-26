script "stack_revResourceCenter"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local tBranches
local sHiliteColor
-- Whether a resource is currently downloading.
local sResourceDownload
-- Store resource URLs and Paths when they are downloading.
local sResourceDownloadURL
local sResourceDownloadPath

-- These two variables store the type and tag of the last resource requested via resourceDownload
local sResourceType
local sResourceTag

local sOriginalLabelText
local sOriginalLabel

on preOpenStack
   # Load the preferences from the preferences object
   prefLoad
   
   # OK-2009-03-27: Bug 7851.
   set the title of me to the title of me
   
   # OK-2008-03-30 : Bug 7856 - Simplifed resource center prefs system and added lock messages 
   # around these calls, as previously they resulted in resizeStack being called, which reset the resource
   # center's height and location to whatever it was saved with.
   lock messages
   local tWidth
   put prefGet("resourceWidth") into tWidth
   set the width of me to tWidth
   
   local tHeight
   put prefGet("resourceHeight") into tHeight
   set the height of me to tHeight
   
   local tLoc
   put prefGet("resourceLocation") into tLoc
   set the location of me to tLoc
   unlock messages
   
   setGettingStartedBranch
   setUserGuideBranch
   setRevolutionObjectsBranch
   setRevolutionCodingBranch
   setTutorialsBranch
   setSampleScriptsBranch
   setSampleProjectsBranch
   set the cBranches of group "Tree" to tBranches
   send "update" to group "Tree"
   
   local tState
   put prefGet("resourceTree") into tState
   
   if tState is not empty then
      send "setTreeState tState" to group "Tree" of me
   end if
   
   // EJB 6.0 Skin
   updateHeaderFooter
   
   local tCard
   put prefGet("lastCard") into tCard
   if tCard is not empty then
      go to card tCard
   end if
   
   # OK-2008-03-30 : Bug 7856 - Needed due to lock messages higher up.
   resizeStack
end preOpenStack
  

on preOpenCard
   actionUpdate
   resizeStack
   set the right of graphic "ProgressBarGraphic" of group "Actions" of me to the left of group "Actions" of me - 500
end preOpenCard

on openCard
   local tCurrentCard
   put the short name of this card into tCurrentCard
   prefSet "lastCard", tCurrentCard
   prefSave
   contentUpdate
   pass openCard
end openCard

on moveStack
   prefSet "resourceLocation", the location of me
   prefSave
   pass moveStack
end moveStack

on closeStackRequest
   if sResourceDownload is "true" then
      answer "You are currently downloading a resource, are you sure you want to close the stack?" with "Yes" and "No"
      if it is "yes" then
         resourceDownloadCancel
         pass closeStackRequest
      end if
   else
      pass closeStackRequest
   end if
end closeStackRequest

on closeStack
   local tCurrentTree
   send "getTreeState" to group "Tree" of me
   put the result into tCurrentTree
   if tCurrentTree is not empty then
      prefSet "resourceTree", tCurrentTree
      
      local tCurrentCard
      put the short name of this card into tCurrentCard
      prefSet "lastCard", tCurrentCard
   end if
   
   prefSet "resourceWidth", the width of me
   prefSet "resourceHeight", the height of me
   prefSet "resourceLocation", the location of me
   prefSave
   pass closeStack
end closeStack

command setGettingStartedBranch
   # Getting Started
   put urlEncode("0" & return & "false" & return & "Getting Started" & return & 0 & return & "") & return into tBranches
end setGettingStartedBranch

command setRevolutionObjectsBranch
end setRevolutionObjectsBranch

command setRevolutionCodingBranch
end setRevolutionCodingBranch

command setTutorialsBranch
   put urlEncode("0" & return & "false" & return & "Tutorials" & return & 0 & return & "header") & return after tBranches
   # General Sub-branch
   put urlEncode("1" & return & "false" & return & "General" & return & 0 & return & "header") & return after tBranches
   #  General Sub-sub-branch
   put urlEncode("2" & return & "false" & return & "Files and Folders" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "The Geometry Manager" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Arrays" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Callbacks" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Image Viewer" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Image Processing" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Controlling iTunes" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Zip Tool" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Custom Controls" & return & getImageID("general-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Windows Vista" & return & getImageID("general-icon") & return & "") & return after tBranches
   
   # Internet Sub-branch
   put urlEncode("1" & return & "false" & return & "Internet" & return & 0 & return & "header") & return after tBranches
   # Internet Sub-sub-branch
   put urlEncode("2" & return & "false" & return & "Internet Images" & return & getImageID("internet-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "RSS Feeds" & return & getImageID("internet-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Browser Sampler" & return & getImageID("internet-icon") & return & "") & return after tBranches
   
   # Games Sub-branch
   put urlEncode("1" & return & "false" & return & "Games" & return & 0 & return & "header") & return after tBranches
   # Games Sub-sub-branch
   put urlEncode("2" & return & "false" & return & "Hangman" & return & getImageID("games-icon") & return & "") & return after tBranches
   
   # Databases Sub-branch
   put urlEncode("1" & return & "false" & return & "Databases" & return & 0 & return & "header") & return after tBranches
   # Databases sub-sub-branch
   put urlEncode("2" & return & "false" & return & "SQLite" & return & getImageID("database-icon") & return & "") & return after tBranches
   
   # User Interface Sub-branch
   put urlEncode("1" & return & "false" & return & "Graphical Interface" & return & 0 & return & "header") & return after tBranches
   # User Interface sub-sub-branch
   put urlEncode("2" & return & "false" & return & "Skinning" & return & getImageID("UI-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Inks/Windows" & return & getImageID("UI-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Blind Effect" & return & getImageID("UI-icon") & return & "") & return after tBranches
   
   # Externals Sub-branch
   put urlEncode("1" & return & "false" & return & "Externals" & return & 0 & return & "header") & return after tBranches
   # Externals sub-sub-branch
   put urlEncode("2" & return & "false" & return & "Externals Part One" & return & getImageID("Plugin-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Externals Part Two" & return & getImageID("Plugin-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Linux Externals" & return & getImageID("Plugin-icon") & return & "") & return after tBranches
end setTutorialsBranch

command setSampleScriptsBranch
   # Sample Scripts
   put urlEncode("0" & return & "false" & return & "Sample Scripts" & return & 0 & return & "header") & return after tBranches
   
   # Sub-branch - Text
   put urlEncode("1" & return & "false" & return & "Text" & return & 0 & return & "header") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Display "&quote&"Hello World"  & quote & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Link text roll over effect" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Show or hide a scrollbar automatically as text is entered in a field" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Limiting the number of characters during data entry" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Accepting only digit characters during data entry" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Shifting selected text to the right or left" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Inserting line breaks to hard wrap text" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Inserting some text before each line in a field" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Combine random text strings" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Repeating a string of text" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Replacing a text style in a field" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Listing all the unique words in a piece of text" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Removing bold text styles from a field" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Reversing text" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Sorting a list" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Truncating text to a specific pixel width" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Text search box" & return & getImageID("text-icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Switching between styled text and HTML source" & return & getImageID("text-icon") & return & "") & return after tBranches
   
   # Sub-branch - Numbers
   put urlEncode("1" & return & "false" & return & "Numbers" & return & 0 & return & "header") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Compare numbers approximately" & return & getImageID("Samples-Numbers") & return & "") & return after tBranches
   
   # Sub-branch - Graphics and Objects
   put urlEncode("1" & return & "false" & return & "Graphics and Objects" & return & 0 & return & "header") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Drag drop a background color onto an object" & return & getImageID("Samples-graphic") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Setting an RGB color channel of an object" & return & getImageID("Samples-graphic") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Translating a color name to an RGB numeric triplet" & return & getImageID("Samples-graphic") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Getting the dimensions of a picture file" & return & getImageID("Samples-graphic") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Scrolling text banner" & return & getImageID("Samples-graphic") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Editing the clipboard" & return & getImageID("Samples-graphic") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Finding common lines in two containers" & return & getImageID("Samples-graphic") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Finding lines that are not common to two containers" & return & getImageID("Samples-graphic") & return & "") & return after tBranches
   
   # Sub-branch - Menus
   put urlEncode("1" & return & "false" & return & "Menus" & return & 0 & return & "header") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Text menu: populating with content" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Text menu: handling choices" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Text menu: updating check marks" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Placing a check next to a menu item" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Placing a font list into a menu" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Updating a menu with a list of open windows" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Dynamic card creation navigation menu" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Responding to a choice in a Window menu" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Popping up a menu after a delay timer" & return & getImageID("Samples-Menus") & return & "") & return after tBranches
   
   # Sub-branch - User Interface
   put urlEncode("1" & return & "false" & return & "User Interface" & return & 0 & return & "header") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Searching for an open window by title" & return & getImageID("UI-Icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Speaking an alert message" & return & getImageID("UI-Icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Centering a window on the screen" & return & getImageID("UI-Icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Check whether the screen resolution is high enough" & return & getImageID("UI-Icon") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Find out the current platform and system version" & return & getImageID("UI-Icon") & return & "") & return after tBranches
   
   # Sub-branch - Printing
   put urlEncode("1" & return & "false" & return & "Printing" & return & 0 & return & "header") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Fitting a Printout to the Page" & return & getImageID("Samples-Printing") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Printing all cards that contain a word" & return & getImageID("Samples-Printing") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Printing all the fields on a card" & return & getImageID("Samples-Printing") & return & "") & return after tBranches
   
   
   # Sub-branch - Applications
   put urlEncode("1" & return & "false" & return & "Applications" & return & 0 & return & "header") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Displaying a count down (blocking)" & return & getImageID("window-objects") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Displaying a count down (non-blocking)" & return & getImageID("window-objects") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Simple slide show" & return & getImageID("window-objects") & return & "") & return after tBranches
   
   # Sub-branch - Miscellaneous
   put urlEncode("1" & return & "false" & return & "Miscellaneous" & return & 0 & return & "header") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Check whether a directory or drive is write-protected" & return & getImageID("Samples-Misc") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Converting a relative path to an absolute path" & return & getImageID("Samples-Misc") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Converting an absolute path to a relative path" & return & getImageID("Samples-Misc") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Storing a modification timestamp" & return & getImageID("Samples-Misc") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Converting between characters and numerical (ASCII) values" & return & getImageID("Samples-Misc") & return & "") & return after tBranches
   put urlEncode("2" & return & "false" & return & "Listing all the handlers in a script" & return & getImageID("Samples-Misc") & return & "") & return after tBranches
end setSampleScriptsBranch

command setSampleProjectsBranch
   # Sample Projects
   put urlEncode("0" & return & "false" & return & "Sample Projects" & return & 0 & return & "header") & return after tBranches
   # Sub-branches Projects
   put urlEncode("1" & return & "false" & return & "Internet Chat" & return & getImageID("sampleprojects-icon") & return & "") & return after tBranches
   put urlEncode("1" & return & "false" & return & "Simple Calculator" & return & getImageID("sampleprojects-icon") & return & "") & return after tBranches
   put urlEncode("1" & return & "false" & return & "Video Capture" & return & getImageID("sampleprojects-icon") & return & "") & return after tBranches
   put urlEncode("1" & return & "false" & return & "Bouncy" & return & getImageID("sampleprojects-icon") & return & "") & return after tBranches
end setSampleProjectsBranch

command setUserGuideBranch
   #  User Guide
   put urlEncode("0" & return & "false" & return & "User Guide" & return & 0 & return & "") & return after tBranches
end setUserGuideBranch

function getImageID pImageName
   return (the id of image pImageName of stack "revIcons")
end getImageID


---------------------- Resource Related ----------------------
## These deal with the video tutorials, their related pdfs,
## the sample projects and the sample scripts
----------------------------------------------------------------

command downloadResource pResourceType, pResourceName
   if not resourceAvailable(pResourceType, pResourceName) then
      resourceDownload pResourceType, pResourceName
   else
      resourceLaunch pResourceType, pResourceName
   end if
end downloadResource

function resourceAvailable pType, pTag
   if pType is "script" or pTag is "userguide" then
      return "true"
   else
      return there is a file (resourceGetFolder(pType, false) & slash & (resourceLocalFilename(pType, pTag)))
   end if
end resourceAvailable
  
function resourceGetFolder pType, pCreate
   local tFolder
   switch pType 
      case "Video" 
         return revEnvironmentUserResourcesPath("Video Tutorials", pCreate)
      break
      case "pdf"
         put revEnvironmentUserResourcesPath("Video Tutorials", pCreate) into tFolder
         return tFolder
      break
      case "stack"
         return revEnvironmentUserResourcesPath("Tutorials", pCreate)
   end switch
end resourceGetFolder

function resourceFilename pType, pTag
   set the itemDelimiter to "."
   delete the last item of pTag
   switch pType
      case "PDF"
         return pTag & ".pdf"
      break
      case "Video"
         return pTag & ".avi"
      break
      default
         return pTag & ".rev"
      break
   end switch
end resourceFilename

function resourceLocalFilename pType, pTag
   local tType, tTag
   -----------------
   put pType into tType
   put pTag into tTag  
   set the itemDelimiter to "."
   delete the last item of tTag
   switch tType
      case "PDF"
         return resourceTag2Local(tTag) & ".pdf"
      break
      case "Video"
         return resourceTag2Local(tTag) & ".avi"
      break
      default
         return resourceTag2Local(tTag) & ".rev"
   end switch
end resourceLocalFilename

function resourceTag2Local pTag
   return pTag
end resourceTag2Local

function resourceLocal2Tag pFilename
   return pFilename
end resourceLocal2Tag

on resourceLaunch pType, pTag
   local tTag, tFile
   put pTag into tTag
   switch pType
      case "Video"
         local tSource
         put resourceGetFolder("Video") & slash & resourceLocalFilename(pType,tTag) into tSource
         set the cSource of card "Video Viewer" to resourceGetFolder("Video") & slash & resourceLocalFilename(pType,tTag)
         go to card "Video Viewer"
      break
      case "pdf"
         if pTag is "userguide" then
            documentationLaunchUserGuide
         else
            put resourceGetFolder("pdf") & slash & resourceLocalFilename(pType, tTag) into tFile
            if there is a file tfile then
               revGoPDF tFile
            else
               error "Revdocs, can't open pdf. File:" && tFile && "does not exist"
            end if
         end if
      break
      case "stack"
         put resourceGetFolder("stack", true) & slash & tTag into tFile
         go stack tFile
   end switch
   set the itemDelimiter to comma
end resourceLaunch

on documentationLaunchUserGuide
   revIDELaunchResource "User Guide"
end documentationLaunchUserGuide

private command updateDownloadGroupLabel pTarget
   local tOwner
   put the long id of the owner of pTarget into tOwner
   
   if word 1 of the name of tOwner is not "group" then
      exit updateDownloadGroupLabel
   end if
   
   local tField
   if the number of fields of tOwner > 0 then
      put the long id of field 1 of tOwner into tField
   end if
   
   put the text of tField into sOriginalLabelText
   put the long id of tField into sOriginalLabel
   
   set the text of tField to "Downloading"
end updateDownloadGroupLabel

private command restoreDownloadGroupLabel
   if sOriginalLabel is not empty then
      set the text of sOriginalLabel to sOriginalLabelText
   end if
end restoreDownloadGroupLabel

constant kResourceLocation = "http://resources.runrev.com/"
local sDownloadPercentage

on resourceDownload pType, pTag
   local tLocalPath, tRemotePath, tLeaf, tLocalfilename
   updateDownloadGroupLabel the long id of the target
   put 0 into sDownloadPercentage -- Lg 2008-06-25
   put resourceLocalFilename(pType,pTag) into tLocalFilename
   
   put resourceFilename(pType, pTag) into tLeaf
   put resourceGetFolder(pType, true) & slash & tLocalFilename into tLocalPath
   
   if pType is "stack" then
      put "http://livecodeshare.runrev.com/resources/tutorials/" & tLeaf into tRemotePath
   else
      put "http://livecodeshare.runrev.com/resources/video/" & tLeaf into tRemotePath
   end if
   
   if sResourceDownload is "true" then
      resourceDownloadCancel
   end if
   
   put "true" into sResourceDownload
   put tRemotePath into sResourceDownloadURL
   put tLocalPath into sResourceDownloadPath
   put pType into sResourceType
   put pTag into sResourceTag
   
   put 0 into sDownloadPercentage
   libURLSetStatusCallback "resourceDownloadStatusCallback", the long id of me
   set the fileType to "PDF prvw"
   libURLDownloadToFile sResourceDownloadURL, tLocalPath, "resourceDownloadCallback"
end resourceDownload
  

----

constant kServerURL = "http://revonline.runrev.com/cgi-bin/resources.cgi"


on resourceDownloadStatusCallback pURL, pStatus
   if item 1 of pStatus is "loading" then
      local tReceived
      put item 2 of pStatus into tReceived
      
      local tTotal
      put item 3 of pStatus into tTotal
      
      if tTotal > 0 then
         get (tReceived / tTotal) * 100
         put round(it) into sDownloadPercentage
      end if
   end if
   
   send "updateProgress sDownloadPercentage" to stack "revRCDownloadProgress"
end resourceDownloadStatusCallback
  

on resourceDownloadCallback pURL, pStatus
   if pStatus is not "downloaded" then
      delete file sResourceDownloadPath
   end if
   put empty into sResourceDownloadURL
   put empty into sResourceDownloadPath
   
   resourceLaunch sResourceType, sResourceTag
   
   put "false" into sResourceDownload
   set the right of graphic "ProgressBarGraphic" of group "Actions" of me to the left of group "Actions" of me - 500
   close stack "revRCDownloadProgress"
   actionUpdate
end resourceDownloadCallback

on resourceDownloadCancel
   set the cResourceDownloading of this stack to false
   if sResourceDownloadURL is "Licensed Download" then
      send "rvoSecureCancel" to stack "revOnline"
   else 
      unload url sResourceDownloadURL
   end if
   
   if sResourceDownloadURL is not empty then
      unload url sResourceDownloadURL
      put empty into sResourceDownloadURL
      if there is no file sResourceDownloadPath then
      end if
      delete file sResourceDownloadPath
      put empty into sResourceDownloadPath
      if the short name of this card is "Tutorial Chooser" then
         --send "resourceDownloadCompleted cancelled" to this card of me
      end if
   end if
   put "false" into sResourceDownload
   restoreDownloadGroupLabel
end resourceDownloadCancel

function resourceWarnDownloadCancel
   if the cResourceDownloading of this stack then
      answer "A file is currently downloading, would you like to stop it?" with "Stop Download" or "Cancel" as sheet
      if it is "Cancel" then
         return false
      else
         return true
      end if
   else
      return true
   end if
end resourceWarnDownloadCancel

--constant kResourceLocation = "http://revonline.runrev.com/resources/"

command launchExampleStack pStack
   local tResourcePath
   put resourceGetFolder("Project", true) into tResourcePath
   put tResourcePath & "/" & pStack into tResourcePath
   open stack tResourcePath
end launchExampleStack

command launchstack pStackName
   local tLocation
   put kResourceLocation & "tutorials/" & pStackName & ".rev" into tLocation
   go stack URL tLocation
end launchstack

command testLaunch pStackName
   local tLocation, tLocalFilename, tLocalPath
   put kResourceLocation & "tutorials/" & pStackName & ".rev" into tLocation
   updateDownloadGroupLabel
   animateFieldStart
   go stack URL tLocation
   resourceDownloadCallback
end testLaunch


local sAnimatingField
local sAnimationState
local sAnimationOriginalText
local sAnimationStopped = "false"
local sAnimationMessage

constant kAnimationRate = 250

command animateFieldStart pField
   put 1 into sAnimationState
   put the long id of pField into sAnimatingField
   put the text of pField into sAnimationOriginalText
   animationUpdateState
   send "animateIncrementState" to me in kAnimationRate milliseconds
   put the result into sAnimationMessage
end animateFieldStart

command animateFieldStop
   if sAnimationMessage is not empty then
      cancel sAnimationMessage
      put empty into sAnimationMessage
   end if
   
   if sAnimatingField is not empty then
      set the text of sAnimatingField to sAnimationOriginalText
   end if
   
   put empty into sAnimationState
   put empty into sAnimatingField
   put empty into sAnimationOriginalText
   put false into sAnimationStopped
end animateFieldStop

command animateIncrementState
   if sAnimationState > 3 then
      put 1 into sAnimationState
   else
      add 1 to sAnimationState
   end if
   
   animationUpdateState
   
   send "animateIncrementState" to me in kAnimationRate milliseconds
   put the result into sAnimationMessage
end animateIncrementState

private command animationUpdateState
   local tText
   switch sAnimationState
      case 1
         put sAnimationOriginalText & "   " into tText
      break
      case 2
         put sAnimationOriginalText & ".  " into tText
      break
      case 3
         put sAnimationOriginalText & ".. " into tText
      break
      case 4
         put sAnimationOriginalText & "..." into tText
      break
   end switch
   
   if sDownloadPercentage is not empty then
      set the text of sAnimatingField to tText && sDownloadPercentage & "%"
   else
      set the text of sAnimatingField to tText
   end if
end animationUpdateState

on linkClicked pLink
   revGoUrl pLink
end linkClicked

on rawKeyDown pKey
   if pKey is 65308 then
      moveScrollbarDown
   else if pKey is 65309 then
      moveScrollbarUp
   else 
      pass rawKeyDown
   end if
end rawKeyDown

constant kGroupScrollLineInc = 50

command moveScrollbarDown
   local tGroup
   put resolveScrollableGroup() into tGroup
   if tGroup is empty then
      exit moveScrollbarDown
   end if
   
   set the vScroll of tGroup to the vScroll of tGroup + kGroupScrollLineInc
end moveScrollbarDown

command moveScrollbarUp
   local tGroup
   put resolveScrollableGroup() into tGroup
   if tGroup is empty then
      exit moveScrollbarUp
   end if
   
   set the vScroll of tGroup to the vScroll of tGroup - kGroupScrollLineInc
end moveScrollbarUp

private function listGroups
   local tGroups
   repeat with x = 1 to the number of groups of this card of me
      put the long id of group x of this card of me & return after tGroups
   end repeat
   delete the last char of tGroups
   return tGroups
end listGroups


-- If there is a scrollable (i.e visible and with vertical scrollbar) group under the cursor
-- returns a reference to that group, otherwise returns empty.
function resolveScrollableGroup
   local tMouseX, tMouseY
   get the mouseLoc
   put item 1 of it into tMouseX
   put item 2 of it into tMouseY
   
   local tBackgroundGroups
   put the backgroundNames of this stack into tBackgroundGroups
   
   
   repeat for each line tGroup in listGroups()
      if not pointInRect((tMouseX, tMouseY), the rect of tGroup) then 
         next repeat
      end if
      
      if the visible of tGroup and the vScrollbar of tGroup then
         return the long id of tGroup
      end if
   end repeat
   return empty
end resolveScrollableGroup

private function pointInRect pPoint, pRect
   if item 1 of pPoint < item 1 of pRect then
      return false
   end if
   
   if item 1 of pPoint > item 3 of pRect then
      return false
   end if
   
   if item 2 of pPoint < item 2 of pRect then
      return false
   end if
   
   if item 2 of pPoint > item 4 of pRect then
      return false
   end if
   
   return true
end pointInRect

command log pMessage
   put pMessage & return after msg
end log

local tCount = 1
local tStackName, tImage

on mouseDoubleUp
   local tCopy
   if word 1 of the target is "image" then
      put the target into tImage
      createSubstack tImage
      put tCount + 1 into tCount
      send "zoomIn" to me in 0 milliseconds
   end if
end mouseDoubleUp

command createSubstack pImage
   put "revSubstack" & tCount into tStackName
   set the right of the templateStack to -1000
   create stack
   set the name of it to tStackName
   set the title of stack tStackName to "Image Viewer"
   set the resizable of stack tStackName to "false"
   copy pImage to stack tStackName
   reset the templateStack
end createSubstack

command zoomIn
   set the width of image tImage of stack tStackName to (the width of image tImage of stack tStackName * 2)
   set the height of image tImage of stack tStackName to (the height of image tImage of stack tStackName * 2)
   set the width of stack tStackName to the width of image tImage of stack tStackName
   set the height of stack tStackName to the height of image tImage of stack tStackName
   set the loc of stack tStackName to the screenLoc
   set the location of image tImage of stack tStackName to (the loc of this card of stack tStackName)
end zoomIn

command contentUpdate pHorizontalDelta, pTreeSplit
   local tObjectArray
   
   repeat with x = 1 to the number of controls of group "mainContent" of this card of me
      local tObject
      put the long id of control x of group "mainContent" of this card of me into tObject
      if not the cContentObject of tObject then
         next repeat
      end if
      put tObject into tObjectArray[the top of tObject]
   end repeat
   
   local tKeys
   put the keys of tObjectArray into tKeys
   sort tKeys numeric
   
   local tContentObjects
   set the itemDelimiter to tab
   repeat for each line tKey in tKeys
      put tObjectArray[tKey] & return after tContentObjects
   end repeat
   delete the last char of tContentObjects
   set the itemDelimiter to comma
   
   lock screen
   local tLastRect
   repeat for each line tObject in tContentObjects
      contentUpdateSize tObject
      contentUpdateLocation tObject, pHorizontalDelta, tLastRect, pTreeSplit
      put the rect of tObject into tLastRect
   end repeat
   unlock screen
end contentUpdate

private command contentUpdateSize pObject
   if word 1 of the name of pObject is not "field" then
      exit contentUpdateSize
   end if
   local tTopLeft
   put the topLeft of pObject into tTopLeft
   
   local tNewWidth
   put the width of group "mainContent" of this card of me - 15 into tNewWidth
   if tNewWidth >= 0 then
      set the width of pObject to tNewWidth
   else
      set the width of pObject to 0
   end if
   
   set the height of pObject to the formattedHeight of pObject
   set the topLeft of pObject to tTopLeft
end contentUpdateSize

private command contentUpdateLocation pObject, pHorizontalDelta, pLastRect, pTreeSplit
   set the loc of pObject to (item 1 of the loc of group "mainContent" of this card of me), (item 2 of the loc of pObject)
   if pLastRect is not empty then
      set the top of pObject to item 4 of pLastRect
   end if
end contentUpdateLocation

command actionUpdate
   local tLeftName, tRightName, tLeftType, tRightType
   if the id of this card of me is not "91444" then
      put actionGetName(the short name of this card of me, "left") into tLeftName
      put actionGetName(the short name of this card of me, "right") into tRightName
      
      put actionGetType(the short name of this card of me, "left") into tLeftType
      put actionGetType(the short name of this card of me, "right") into tRightType
   else
      put actionGetName("Display HelloWorld", "right") into tRightName
      put actionGetType("Display HelloWorld", "right") into tRightType
      put empty into tLeftName
      put empty into tLeftType
   end if
   
   
   local tLeftIcon, tRightIcon
   put actionGetIcon(tLeftType) into tLeftIcon
   put actionGetIcon(tRightType) into tRightIcon
   
   set the cLeftName of group "Actions" of me to tLeftName
   set the cRightName of group "Actions" of me to tRightName
   set the cLeftType of group "Actions" of me to tLeftType
   set the cRightType of group "Actions" of me to tRightType
   set the cLeftIcon of group "Actions" of me to tLeftIcon
   set the cRightIcon of group "Actions" of me to tRightIcon
   send "update" to group "Actions" of me
end actionUpdate
  

private function actionGetName pCardName, pSide
   return the cNames[pCardName,pSide] of me
end actionGetName

private function actionGetType pCardName, pSide
   return the cTypes[pCardName,pSide] of me
end actionGetType

private function actionGetIcon pType
   switch pType
      case "stack"
         return 205288
      break
      case "video"
         return 205286
      break
      case "pdf"
         return 205285
      break
      case "script"
         return 205290
      break
   end switch
end actionGetIcon

command findContentGroups
   local tBackground = 2127
   
   local tStartCard = 1
   
   local tIds, tMatchingIds
   repeat with x = tStartCard to the number of cards of me
      if the short name of card x is "Video Viewer" then
         next repeat
      end if
      
      put the groupIds of card x of me into tIds
      
      local tMatchingGroupId
      repeat for each line tGroupId in tIds
         put empty into tMatchingGroupId
         
         local tName
         put the short name of group id tGroupId of card x of me into tName
         
         if tGroupId is tBackground then
         else
            put tGroupId into tMatchingGroupId
            exit repeat
         end if
      end repeat
      put tMatchingGroupId & return after tMatchingIds
   end repeat
   delete the last char of tMatchingIds
   
   local tCounter
   put 1 into tCounter
   repeat with x = tStartCard to the number of cards of me
      try
         if the short name of card x is "Video Viewer" then
            next repeat
         end if
         
         go to card x
         
         repeat with y = 1 to the number of controls of group id (line tCounter of tMatchingIds)
            if the long owner of control y of group id (line tCounter of tMatchingIds) is not the long name of group id (line tCounter of tMatchingIds) then
               set the cContentObject of control y of group id (line tCounter of tMatchingIds) to false
            end if
         end repeat
         
      catch tError
         log "Error opening card: " & the short name of card x
         log tError
         exit repeat
      end try
      
      if mouse(1) is "down" then
         exit repeat
      end if
      
      add 1 to tCounter
   end repeat
end findContentGroups

function revDocumentationDefaultPref pPref
   switch pPref
      case "mode"
         return "horizontal"
         break
      case "columns"
         --         return "Keyword,Type,Syntax,Synonyms,Class,Platforms,Security,Version,Date,Notes,Library,Button,Field,Graphic,Scrollbar,Image,Player,Card,Stack,Group"
         return "Keyword,Type,Syntax,Synonyms,Platforms,Operating Systems,Security,Version,Date,Notes,Library,Button,Field,Graphic,Scrollbar,Image,Player,Card,Stack,Group"
         break
      case "columnMinWidths"
         return  "20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20"
         break
      case "columnVisibility"
         return "true,true,true,false,true,true,true,false,false,false,false,false,false,false,false,false,false,false,false,false"
         break
      case "columnWidths"
         return "110,62,440,150,90,90,90,60,55,240,150,30,30,30,30,30,30,30,30,30"
         break
      case "borderColor"
         return "192,192,192"
         break
      case "indexHorizontalSplit"
         return 300
         break
      case "indexVerticalSplit"
         return 250
         break
      case "treeSplit"
         return 150
         break
      case "lastEntry"
         return "split,1656.xml,operator,dictionary"
         break
      case "lastEntryNew"
         return empty
         break
      case "lastEntryNewSetInBuild"
         return empty
         break
      case "location"
         return the screenLoc
         break
      case "width"
         return 764
         break
      case "height"
         return 476
         break
         
         # OK-2008-11-27 : Added preferences for comments system
      case "cacheSize"
         return 50
         break
      case "cacheValidity"
         return 300
         break
      case "commentCount"
         return 10
         break
      case "sortDirection"
         return "DESC"
         break
      case "useScrollbar"
         return "false"
         break
         
         # OK-2009-03-30 : Resource center defaults
      case "resourceLocation"
         return the screenLoc
         break
      case "resourceWidth"
         return 687
         break
      case "resourceHeight"
         return 587
         break
         
         
   end switch
end revDocumentationDefaultPref

local sPrefs

# Returns
#   A reference to the object to store preferences on
private function prefObject
   return the name of stack "revPreferences"
end prefObject

# Description
#   Loads the preferences from the preferences object into the array sPrefs
#   The preferences will be reloaded by default unless false is explicitly passed
#   as the pReload value.
command revDocumentationPrefLoad pReload
   if sPrefs is an array and (pReload is not "false") then
      exit revDocumentationPrefLoad
   end if
   
   put the cDictionaryMode of prefObject() into sPrefs["mode"]
   
   # OK-2009-09-14 : Changed the internal property names of these properties
   # to prevent incompatibility with older versions.
   put the cDictionaryColumnVisibilityNew of prefObject() into sPrefs["columnVisibility"]
   put the cDictionaryColumnWidthsNew of prefObject() into sPrefs["columnWidths"]
   put the cDictionaryHorizontalSplit of prefObject() into sPrefs["horizontalSplit"]
   put the cDictionaryLastEntryNew of prefObject() into sPrefs["lastEntryNew"]
   put the cDictionaryLastEntryNewSetInBuild of prefObject() into sPrefs["lastEntryNewSetInBuild"]
   put the cDictionaryVerticalSplit of prefObject() into sPrefs["verticalSplit"]
   put the cDictionaryLocation of prefObject() into sPrefs["location"]
   put the cDictionaryWidth of prefObject() into sPrefs["width"]
   put the cDictionaryHeight of prefObject() into sPrefs["height"]
   put the cDictionaryTree of prefObject() into sPrefs["lastTree"]
   
   # OK-2009-02-05 : Bug 7683
   put the cDictionaryIndexVerticalSplit of prefObject() into sPrefs["indexVerticalSplit"]
   put the cDictionaryTreeSplit of prefObject() into sPrefs["treeSplit"]
   
   put the cResourceLocation of prefObject() into sPrefs["resourceLocation"]
   put the cResourceWidth of prefObject() into sPrefs["resourceWidth"]
   put the cResourceHeight of prefObject() into sPrefs["resourceHeight"]
   put the cResourceTree of prefObject() into sPrefs["resourceTree"]
   
   put the cResourceLastCard of prefObject() into sPrefs["lastCard"]
   
end revDocumentationPrefLoad

# Description
#   Saves the preferences in the preferences object. This should be called whenever the dictionary is closed.
command revDocumentationPrefSave
   set the cDictionaryMode of prefObject() to sPrefs["mode"]
   
   # OK-2009-09-14 : Renamed the internal properties storing the two column preferences
   # to prevent backwards compatibility issues.
   
   -- Don't save column visiblity when in vertical mode.
   if revDocumentationPrefGet("mode") is "horizontal" then
      set the cDictionaryColumnVisibilityNew of prefObject() to sPrefs["columnVisibility"]
   end if
   
   set the cDictionaryColumnWidthsNews of prefObject() to sPrefs["columnWidths"]
   set the cDictionaryIndexHorizontalSplit of prefObject() to sPrefs["indexHorizontalSplit"]
   set the cDictionaryLastEntryNew of prefObject() to sPrefs["lastEntryNew"]
   set the cDictionaryLastEntryNewSetInBuild of prefObject() to sPrefs["lastEntryNewSetInBuild"]
   set the cDictionaryIndexVerticalSplit of prefObject() to sPrefs["indexVerticalSplit"]
   set the cDictionaryTreeSplit of prefObject() to sPrefs["treeSplit"]
   
   # TH-2008-07-22 :: only want to save the rect if it is not iconic
   if the iconic of stack "revDictionary" is "false" then
      --put the executioncontexts
      set the cDictionaryLocation of prefObject() to sPrefs["location"]
      set the cDictionaryWidth of prefObject() to sPrefs["width"]
      set the cDictionaryHeight of prefObject() to sPrefs["height"]
   end if
   
   set the cDictionaryTree of prefObject() to sPrefs["lastTree"]
   
   if the iconic of stack "revResourceCenter" is false then
      set the cResourceLocation of prefObject() to sPrefs["resourceLocation"]
      set the cResourceWidth of prefObject() to sPrefs["resourceWidth"]
      set the cResourceHeight of prefObject() to sPrefs["resourceHeight"]
   end if
   set the cResourceTree of prefObject() to sPrefs["resourceTree"]
   set the cResourceLastCard of prefObject() to sPrefs["lastCard"]
end revDocumentationPrefSave

# Parameters
#   pPref : the name of the preference to set
#   pValue : the new value of the preference
# Description
#   Sets the specified preference in sPrefs. Note that if a preference is set to empty, its default value will be used.
command revDocumentationPrefSet pPref, pValue 
   put pValue into sPrefs[pPref]
end revDocumentationPrefSet

# Parameters
#   pPref : the name of the preference to get
# Returns
#   The value of the preference.
function revDocumentationPrefGet pPref
   local tValue
   put sPrefs[pPref] into tValue
   if tValue is not empty then
      return tValue
   else
      return revDocumentationDefaultPref(pPref)
   end if
end revDocumentationPrefGet

# Description
#   Loads the preferences from the preferences object into the array sPrefs
command prefLoad
   revDocumentationPrefLoad
end prefLoad

# Description
#   Saves the preferences in the preferences object. This should be called whenever the dictionary is closed.
command prefSave
  revDocumentationPrefSave
end prefSave

# Parameters
#   pPref : the name of the preference to set
#   pValue : the new value of the preference
# Description
#   Sets the specified preference in sPrefs. Note that if a preference is set to empty, its default value will be used.
command prefSet pPref, pValue
   revDocumentationPrefSet pPref, pValue
end prefSet

# Parameters
#   pPref : the name of the preference to get
# Returns
#   The value of the preference.
function prefGet pPref
   return revDocumentationPrefGet(pPref)
end prefGet

# OK-2008-03-30 : Bug 7856 - This shouldn't be needed
# Parameters
#   pPref : the name of the preference to get
# Returns
#   The default value of the specified preference
--function prefGetDefault pPref
--  return revResourceDefaultPref(pPref)
--end prefGetDefault

on resizeStack
   lock screen
   
   local tTreeSplit 
   put prefGet("treeSplit") into tTreeSplit
   
   set the topLeft of image "topBanner" to 0,0
   set the height of button "resizeButton" to the height of me - the height of image "topBanner"
   
   set the topleft of button "resizeButton" to (tTreeSplit, the bottom of image "topBanner")
   
   set the rect of group "Tree" to the left of this card, the bottom of image "topBanner", tTreeSplit, the bottom of this card
   set the rect of field "TreeBackground" to the rect of group "Tree"
   send "resizeHighlightBranch" to group "Tree"
   
   local tWidthBefore
   put the width of group "mainContent" into tWidthBefore
   set the rect of group "mainContent" to the right of button "resizeButton", the bottom of image "topBanner", the right of this card, the bottom of this card - 52
   
   
   local tWidthAfter
   put the width of group "mainContent" into tWidthAfter
   
   local tHorizontalDelta
   put tWidthAfter - tWidthBefore into tHorizontalDelta
   
   set the bottomRight of image "footer" to the width of this card, the height of this card
   set the topRight of group "Template Branch" to the bottom of image "footer" + 50, the right of this card + 50
   
   set the width of field "label" of group "right" of group "actions" to the formattedwidth of field "label" of group "right" of group "actions" + 16
   set the rect of group "Actions" to tTreeSplit, the bottom of group "mainContent", the right of this card, the bottom of this card
   set the topLeft of group "Left" of group "Actions" to (the left of group "Actions" + 20, the top of group "Actions")
   set the topRight of group "Right" of group "Actions" to the right of group "mainContent"-20, the bottom of group "MainContent" + 8
   set the topRight of image "topTitle" to the width of this stack-10, 0
   contentUpdate tHorizontalDelta, tTreeSplit
   
   if the short name of this card is "Video Viewer" then
      send "resizePlayer" to card "Video Viewer"
   end if
   
   
   prefSet "resourceWidth", the width of me
   prefSet "resourceHeight", the height of me
   prefSet "resourceLocation", the location of me
   prefSave
   unlock screen
end resizeStack


command copySampleScripts
   local tStack
   put the long id of stack "revGettingStartedScripts" into tStack
   
   local tLabels
   put listCardLabels() into tLabels
   
   put empty
   
   local tCardName
   repeat for each line tLabel in tLabels
      put tLabel into tCardName
      replace space with empty in tCardName
      
      local tGroupName
      put tLabel & " Example" into tGroupName
      replace quote with empty in tGroupName
      
      local tScript
      if there is a group tGroupName of tStack then
         put the long id of group tGroupName of tStack into tScript
         if exists(group "Example" of group "mainContent" of card tCardName) then
            delete group "Example" of group "mainContent" of card tCardName of this stack
         end if
         copy tScript to group "mainContent" of card tCardName
         set the name of it to "Example"
         set the cContentObject of group "Example" of card tCardName to "true"
      else
         log "Not found: " & tGroupName
      end if
   end repeat
end copySampleScripts

private function listCardLabels
   local tLabels
   repeat with x = 1 to the number of controls of group "Tree"
      if not the cBranch of control x of group "Tree" then
         next repeat
      end if
      
      put the cOriginalLabel of control x of group "Tree" & return after tLabels
   end repeat
   delete the last char of tLabels
   return tLabels
end listCardLabels

on updateHeaderFooter
   local tHeaderImage, tFooterImage, tTopTitle
   
   if char 1 of the version < 7 then
      put ideCoreFolderPath("skin","resource-center-top_legacy.png") into tHeaderImage
      put ideCoreFolderPath("skin","resource-center-title_legacy.png") into tTopTitle
   else
      put ideCoreFolderPath("skin","resource-center-top.png") into tHeaderImage
      put ideCoreFolderPath("skin","resource-center-title.png") into tTopTitle
   end if
   
   put ideCoreFolderPath("skin","resource-center-bottom.png") into tFooterImage
   
   
   set the filename of image "topBanner"  of group id 2127 to tHeaderImage
   set the width of image "topBanner" to the formattedWidth of image "topBanner"
   set the topLeft of image "topBanner" of group id 2127 to 0,0
   
   set the filename of image "footer"  of group id 2127 to tFooterImage
   set the width of image "footer" to the formattedWidth of image "footer"
   set the bottomRight of image "footer" of group id 2127 to the width of this stack, the height of this stack
   
   set the filename of image "topTitle"  of group id 2127 to tTopTitle
   set the width of image "topTitle" to the formattedWidth of image "topTitle"
   set the topRight of image "footer" of group id 2127 to the width of this stack- 10, 0
end updateHeaderFooter
