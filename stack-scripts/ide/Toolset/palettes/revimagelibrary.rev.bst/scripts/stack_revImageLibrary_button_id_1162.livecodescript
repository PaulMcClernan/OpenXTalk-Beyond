script "stack_revImageLibrary_button_id_1162"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002) > group "Buttons" (id 1165) > button "Import File..." (id 1162)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tStackName
  put revLibraryStackName(the label of btn "library chooser") into tStackName
  if word 1 to 2 of the label of btn "library chooser" <> "This Stack" then
    set the defaultStack to tStackName
    go inv stack tStackName
    revImportImageFile
    compact stack tStackName
    save stack tStackName
    close stack tStackName
  else
    # OK-2007-11-29 : Bug 5562, don't change the defaultStack until its required
    revImportImageFile the long id of the topStack
  end if
  send "menuPick" && quote & the label of btn "library chooser" of stack "revImageLibrary" & quote to btn "library chooser" of stack "revImageLibrary"
end mouseUp
