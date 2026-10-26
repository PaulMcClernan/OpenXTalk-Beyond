script "stack_revImageLibrary_button_id_1156"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Objects" (id 1150) > group "Buttons" (id 1167) > button "Delete1" (id 1156)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put line (the hilitedLines of fld "objects list") of fld "objects list" into tCardName
  put the cStackName of fld "objects list" into tStackName
  answer "Really delete" && tCardName & "?" with "Cancel" or "Delete" as sheet
  if it is "Cancel" then exit mouseUp
  delete cd tCardname of stack tStackName
  save stack tStackName
  send "menuPick" && the label of btn "library chooser" to btn "Library chooser"
end mouseUp
