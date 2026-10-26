script "stack_revImageLibrary_card_id_1150"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Objects" (id 1150)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopencard
   
   set the maxWidth of this stack to 600
   put revAbsoluteFolderListing(revEnvironmentResourcesPath("Object Libraries")) into tEnvironmentIcons
   put revAbsoluteFolderListing(revEnvironmentUserResourcesPath("Object Libraries")) into tUserIcons
   put revCombineFilePaths(tUserIcons,tEnvironmentIcons) into tFiles
   repeat for each line tFile in tFiles
      if there is a stack tFile then
         # TH : Have added a custom property to allow a more user friendly library display name
         if the cDisplayName of stack tFile is empty then
            put char 4 to -1 of the short name of stack tFile & return after tStacksList
         else
            put the cDisplayName of stack tFile & return after tStacksList
         end if
         put tFile & return after tStackPaths
      end if
   end repeat
   if tStacksList is not empty then
      delete last char of tStacksList
      set the text of btn "library chooser" to tStacksList
      set the cStackPaths of btn "library chooser" to tStackPaths
   else
      set the text of btn "library chooser" to "None Found"
      set the cStackPaths of btn "library chooser" to empty
   end if
   send "menuPick" && line 1 of btn "library chooser" to btn "library chooser"
   revUpdatePalette
end preOpenCard

on revUpdatePalette
  set the defaultStack to "revImageLibrary"
  put the selobj into tSelobj
  if tSelobj is empty or word 1 of tSelobj is among the items of "card,stack" or the cStackName of fld "objects list" is empty then disable btn "Add Selected" 
  else enable btn "Add Selected" 
end revUpdatePalette

on resizeStack
  revUpdateGeometry
end resizeStack

on arrowKey
  if the focusedObject is empty 
  then send "arrowKey" to fld "objects list"
  pass arrowKey
end arrowKey
