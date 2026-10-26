script "stack_revImageLibrary_button_id_1138"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Objects" (id 1150) > button "library chooser" (id 1138)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pWhich
  if the cStackPaths of me is empty then 
    put empty into fld "objects list"
    set the cStackName of fld "objects list" to empty
    send "mouseUp" to fld "objects list"
    exit menuPick
  end if
  if char 1 to 3 of pWhich is "rev" then put char 4 to -1 of pWhich into pWhich
  set the label of me to pWhich
  put line (the menuHistory of me) of the cStackPaths of me into tStackName
  put the cardNames of stack tStackName into fld "objects list"
  if word 1 to 2 of fld "objects list" is "card id" then delete line 1 of fld "objects list"
  set the cStackName of fld "objects list" to tStackName
  set the hilitedLines of fld "objects list" to 1
  send "mouseUp" to fld "objects list"
end menuPick
