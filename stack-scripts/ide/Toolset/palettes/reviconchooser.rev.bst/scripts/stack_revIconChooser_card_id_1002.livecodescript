script "stack_revIconChooser_card_id_1002"
-- Stack file: ide/Toolset/palettes/reviconchooser.rev
-- Object: stack "revIconChooser" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   local tEnvironmentIcons, tUserIcons, tList, tStacksList, tSaveDirectory, tText, tDivider
   put revAbsoluteFolderListing(revEnvironmentResourcesPath("Icon Libraries")) into tEnvironmentIcons
   put revAbsoluteFolderListing(revEnvironmentUserResourcesPath("Icon Libraries")) into tUserIcons
   put revCombineFilePaths(tUserIcons,tEnvironmentIcons) into tList
   repeat for each line l in tList
      if there is no stack l then
         next repeat
      end if
      if char 1 to 6 of the short name of stack l is "revLib" then put char 7 to -1 of the short name of stack l & cr after tStacksList
      else if char 1 to 3 of the short name of stack l is "rev" then put char 4 to -1 of the short name of stack l & cr after tStacksList
   end repeat
   delete last char of tStacksList
   sort tStacksList
   set the directory to tSaveDirectory
   put the text of btn "library chooser" into tText
   
   if the platform is "MacOS"
   then put "-" into tDivider
   else put empty into tDivider
   if tStacksList is not empty
   then put line 1 to 5 tText & cr & tDivider & cr & tStacksList into btn "library chooser"
   else put line 1 to 5 of tText into btn "library chooser"
   send "menuPick" && the label of btn "library chooser" to btn "library chooser"
   set the thumbPosition of scrollbar "iconchooserscrollbar" to 0
   
   # TH-2008-03-06 : Fix for bug 5987
   set the pageIncrement of scrollbar "iconchooserscrollbar" to 20
   set the lineIncrement of scrollbar "iconchooserscrollbar" to 10
end preOpenStack

on updateIDField pIconID
   put pIconID into fld "ID"
end updateIDField

on mouseUp
  if word 1 of the name of the target is "button" then
    if the icon of the target is not 0 then set the cReturnValue of this stack to the icon of the target
    else set the cReturnValue of this stack to empty
    close this stack
  end if
end mouseUp
