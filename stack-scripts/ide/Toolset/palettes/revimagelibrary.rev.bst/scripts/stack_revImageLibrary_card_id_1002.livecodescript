script "stack_revImageLibrary_card_id_1002"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopencard
   if (the platform is "MacOS" and char 1 of the systemVersion is not "1") then
      set the width of sb 1 to 16
   else
      set the width of sb 1 to 20
   end if
   set the maxWidth of this stack to 2000
   if the cSavedWidth of this cd is not empty then
      set the rect of this stack to the topLeft of this stack,the left of this stack+the cSavedWidth of this cd,the bottom of this stack
   end if
   put revAbsoluteFolderListing(revEnvironmentResourcesPath("Icon Libraries")) into tEnvironmentIcons
   put revAbsoluteFolderListing(revEnvironmentUserResourcesPath("Icon Libraries")) into tUserIcons
   put revCombineFilePaths(tUserIcons,tEnvironmentIcons) into tList
   repeat for each line l in tList
      if there is not a stack l then next repeat -- windows placeholder
      if char 1 to 6 of the short name of stack l is "revLib" then put char 7 to -1 of the short name of stack l & cr after tStacksList
      else if char 1 to 3 of the short name of stack l is "rev" then put char 4 to -1 of the short name of stack l & cr after tStacksList
      else put the short name of stack l & cr after tStacksList
   end repeat
   delete last char of tStacksList
   sort tStacksList
   put the text of btn "library chooser" into tText
   if tStacksList is not empty then put line 1 to 4 tText & cr & "-" & cr & tStacksList into btn "library chooser"
   else put line 1 to 4 of tText into btn "library chooser"
   send "menuPick" && the label of btn "library chooser" to btn "library chooser"
   set the loc of grc "marquee" to -200,-200
   set the foreColor of grc "marquee" to the accentColor
   put empty into fld "image id"
   revUpdatePalette
end preOpenCard

on mouseEnter
  if word 1 of the target is "button" and the icon of the target is not empty and the icon of the target is not 0 then set the toolTip of the target to "Image ID" && the icon of the target
  else if word 1 of the target is "Button" then set the toolTip of the target to empty
end mouseEnter

on revUpdatePalette
  disable btn "Import Selected"
  if (the selObj) is empty or "This Stack" is word 1 to 2 of the label of btn "library chooser" then
    disable btn "Import Selected"
  else
    enable btn "Import Selected"
  end if
  if the label of btn "library chooser" is among the items of "-,Standard Images,Classic Images,Cursors" then
    disable btn "Import Selected"
    disable btn "Import File..."
  else
    enable btn "Import File..."
  end if
end revUpdatePalette

function revLibraryStackName pWhich
  if char 1 to 6 of pWhich is "revLib" then put char 7 to -1 of pWhich into pWhich
  else if char 1 to 3 of pWhich is "rev" then put char 4 to -1 of pWhich into pWhich
  if pWhich is "Standard images" then
    put "revGeneralIcons" into tStackName
  else if pWhich is "MetaCard Compatible Icons" then
    put "revCompatibilityIcons1" into tStackName
  else if pWhich is "Cursors" then
    put "revCustomCursors" into tStackName
  else if word 1 to 2 of pWhich is "this stack" then
    put the short name of the topStack into tStackName
  else put "revLib" & pWhich into tStackName
  return tStackName
end revLibraryStackName

on closeCard
  set the cSavedWidth of this cd to the width of this cd
end closeCard
