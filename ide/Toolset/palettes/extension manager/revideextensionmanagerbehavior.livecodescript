script "revIDEExtensionManagerBehavior" with behavior "revPaletteBehavior"
on preOpenStack
   lock screen
   dispatch "setAsBehavior" to revIDEFrameBehavior() with the long id of this me
   
   set the behavior of card "web" of me to the long id of stack "revIDEExtensionManagerStoreBehavior"
   set the behavior of card "list" of me to the long id of stack "revIDEExtensionManagerListBehavior"
   set the zoomBox of this stack to false
   
   clearFrameData
   
   # Navigation
   -- addFrameItem pName, pLocation, pItemType, pLabel, pIcon, pIconSelected, pCallbackMessage, pCallbackTarget, pParameter
   addFrameItem "widget","header", "navigation", "Widgets", "", "","showList", the long id of me,"widget"
   addFrameItem "library","header", "navigation", "Libraries", "", "","showList", the long id of me,"library"
   -- addFrameItem "sample","header", "navigation", "Sample Stacks", "", "","showList", the long id of me,"sample"
   -- addFrameItem "snippet","header", "navigation", "Snippets", "", "","showList", the long id of me,"snippet"
   addFrameItem "repo","header", "navigation", "Repo", "", "","showExtensionStore", the long id of card "web" of me,"repo"
   addFrameItem "playground","header", "navigation", "Playground", "", "","showWebPlaygound", the long id of card "web" of me,"playground"
   addFrameItem "install", "header", "action", "Install extension", "plus", "","installNew", the long id of me
   
   set the hilitedTabColor of me to "255,255,255"
   set the navigationDisplayStyle of me to "names"
   unlock screen
end preOpenStack

on showList pSection
   lock screen
   send "showList pSection" to card "list" of this stack
   unlock screen
end showList

command refreshList
   lock screen
   send "refreshList" to card "list" of this stack
   unlock screen
end refreshList

on showExtensionStore
   hiliteFrameItem "repo"
   -- browserHide
   lock screen
   set the goSection of this stack to "Repo"
   -- go to card "web" of this stack
   -- set the userAgent of widget "browser" of card "web" of this stack to "OpenXTalk IDE"
   --set the URL of widget "Browser" of card "web" of this stack to "https://openxtalk-org.github.io/OpenXTalk-Playground/Widgets/index.html" --  "https://openxtalk-org.github.io/OpenXTalk-Playground/"
   if the URL of widget "Browser" of card "web" of this stack <> "https://openxtalk-org.github.io/OXT_Resource_Depot_Repo/" then
      set the URL of widget "Browser" of card "web" of this stack to "https://openxtalk-org.github.io/OXT_Resource_Depot_Repo/" --  "https://openxtalk-org.github.io/OpenXTalk-Playground/"
      --send ("doXTscriptInWidget "& quote &"go last"&quote) to me --  in 2 seconds
      -- send ("doXTscriptInWidget "& quote &"go last"&quote) to me in 7 seconds
      -- else
      -- doXTscriptInWidget "go last" --- no longer needed as there is only 1 card in the new res depot web-stack
   end if
   unlock screen
   go card "web" of this stack
end showExtensionStore

on showWebPlaygound
   hiliteFrameItem "playground"
   -- browserHide
   lock screen
   set the goSection of this stack to "Playground"
   -- 
   -- set the userAgent of widget "browser" of card "web" of this stack to "OpenXTalk IDE"
   if the URL of widget "Browser" of card "web" of this stack <> "https://openxtalk-org.github.io/OpenXTalk-Playground/" then
      set the URL of widget "Browser" of card "web" of this stack to "https://openxtalk-org.github.io/OpenXTalk-Playground/" --  "https://openxtalk-org.github.io/OpenXTalk-Playground/"
      --send ("doXTscriptInWidget "& quote &"go first"&quote) to me  -- in 1 seconds
      -- send ("doXTscriptInWidget "& quote &"go first"&quote) to me in 7 seconds
   -- else
      -- doXTscriptInWidget "go first"
   end if
   -- doXTscriptInWidget "go first"
   unlock screen
   go card "web" of this stack
   -- browserShow
end showWebPlaygound

on preferenceChanged pPreference, pValue
   revIDESetPreference pPreference, pValue
end preferenceChanged

on installNew
   answer file "Choose an extension to install:" with type "Extension Builder|lce"
   if it is not empty and it ends with ".lce" then 
      -- put it into pFileName
      installExtension it, "", "widget"
   end if
end installNew

on installExtension pExtensionPathOrURL, pTypeID, pType
   lock screen
   showList pType
   if pExtensionURL begins with "http" then
      // get from extensions store
      unlock screen
      -- "org.openxtalk.hh.svgtext.1.5.3.lce.b64"
      put cr& "insall Remote Extension URL="& pExtensionURL & ", TypeID="& pTypeID & ", Type=" & pType after msg -- for checking
      lock screen
      revIDEExtensionDownloadAndInstall pExtensionPathOrURL, pType
   else if pExtensionURL begins with "data:" then -- data:text/plain;base64,SGVsbG8gV29ybGQh
      -- do Base64 Encoded File Conversion"
      put "Received Data URI:"&cr & pExtensionURL
   else
      // get from local .lce file
      revIDEExtensionInstall pExtensionPathOrURL, pType
   end if
   unlock screen
end installExtension

--function resManagerDownloadDir
--   return revIDECustomizationFolder
--end resManagerDownloadDir

on installExtensionB64Decode pExtensionB64Encoded, pResID, pExtensionType
   if pResID is empty then
      ask file "Save Binary as..." with "File.lce"
      if it is not empty then 
         put it into tFile
      end if
   else
      put revIDESpecialFolderPath("downloading extensions")  &"/"& pResID &".lce" into tFile
   end if
   if tFile is not empty then
      open file tFile for binary write
      write base64Decode(pExtensionB64Encoded) to file tFile
      close file tFile
      installExtension tFile, pResID, "widget" -- pType
   end if
end installExtensionB64Decode

on doXTscript pXTScript
   -- put pXTScript
   do pXTscript
   if the result contains "error" then 
      throw the result
   end if
end doXTscript

on doXTscriptInWidget pXTScript
   put "var thisStack = document.liveCode.findStackWithName('WebStack');" & cr &\
         "thisStack.doXTscript('" & pXTScript & "');" & cr into tJS
   -- put tJS -- for checking the javascripts formation
   do tJS in widget "Browser" of card "Web" of this stack
   if the result contains "error" then 
      throw the result
   end if
end doXTscriptInWidget

on navSelected pItemName
   -- put "navSelected " & pItemName & cr
   if pItemName is "Repo" then
      -- put pItemName
      -- set the goSection of this stack to "Repo"
      send "showExtensionStore" to this stack -- in 50 millisecs
      exit navSelected
   end if
   if pItemName is "Playground" then
      -- set the goSection of this stack to "Playground"
      -- put pItemName
      send "showWebPlaygound" to this stack -- in 50 millisecs
      exit navSelected
   end if
   pass navSelected
end navSelected
