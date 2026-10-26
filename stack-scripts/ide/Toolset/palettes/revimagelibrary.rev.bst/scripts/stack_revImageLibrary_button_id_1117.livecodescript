script "stack_revImageLibrary_button_id_1117"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002) > button "New..." (id 1117)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tHighID
  put 230000 into tHighID
  put the name of this stack into tLibStackName
  ask "Enter a name for the new image library." with "Untitled library" as sheet
  if it is empty then exit mouseUp
  put it into tLibraryName
  if char 1 to 6 of tLibraryName is not "revLib" then put "revLib" before tLibraryName
  if there is a stack tLibraryName then
    answer error "A library with the same name as this library already exists." with "Cancel"
    exit mouseUp
  end if
  put revAbsoluteFolderListing(revEnvironmentUserResourcesPath("Icon Libraries",true)) into tList
  put cr & "revGeneralIcons" & cr & "revCompatibilityIcons1" after tList
  repeat for each line l in tList
    if l is empty or there is not a stack l then next repeat
    if the name of stack l is tLibraryName then
      answer error "That library already exists." with "Cancel"
      exit mouseUp
    end if
    put the ID of stack l into item (the number of items in tHighID+1) of tHighID
  end repeat
  if there is a file (tLibraryName & ".rev") then
    answer error "A library with the name" && tLibraryName & ".rev" && "already exists." with "Cancel"
    exit mouseUp
  end if
  set the name of the templateStack to tLibraryName
  set the destroyStack of the templateStack to false
  lock messages
  set the style of the templateStack to "modeless"
  create invisible stack
  reset the templateStack
  set the mainStack of stack tLibraryName to tLibraryName
  set the ID of stack tLibraryName to (max(tHighID)+1000)
  set the fileName of stack tLibraryName to revEnvironmentUserResourcesPath("Icon Libraries") & "/" & tLibraryName & ".rev"
  save stack tLibraryName
  lock screen
  send "preOpenCard" to this cd of stack tLibStackName
  send "revUpdatePalette" to this cd of stack tLibStackName
  send "menuPick" && tLibraryName to btn "library chooser"
  set the menuHistory of btn "Library chooser" to the number of lines in btn "Library chooser"
  set the label of btn "library chooser" to char 7 to -1 of tLibraryName
  unlock screen
  unlock messages
  set the menuHistory of btn "library chooser" to lineOffset(char 7 to -1 of tLibraryName,the text of btn "library chooser")
end mouseUp

on mouseEnter
  
end mouseEnter
