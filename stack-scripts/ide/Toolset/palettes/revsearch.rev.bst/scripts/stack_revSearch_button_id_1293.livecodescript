script "stack_revSearch_button_id_1293"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > button "Search In" (id 1293)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lLastItem

on mouseDown
  put the label of me into lLastItem
  set the menuHistory of me to lineOffset(the label of me,the text of me)
end mouseDown
  
on menuPick pWhich
  if pWhich is empty then
    set the label of me to lLastItem
    exit menuPick
  end if
  
  set the label of me to pWhich
  lock screen
  if "global" is not in pWhich then enable group "properties"
  else disable group "properties"
  switch pWhich
  case "specific open stack file"
    set the loc of grp "specific stack" of stack "revSearch" to the cOnScreenLoc of grp "specific stack" of stack "revSearch"
    set the loc of grp "folder" of stack "revSearch" to the cOffScreenLoc of grp "folder" of stack "revSearch"
    set the text of fld "label" of stack "revSearch" to "Stack"
    set the loc of fld "disabled" of stack "revSearch" to the cOffScreenLoc of fld "disabled" of stack "revSearch"
    enable fld "label" of stack "revSearch"
    set the text of fld "specific stack" of stack "revSearch" to the short name of the topStack
    select after text of fld "specific stack" of stack "revSearch"
    break
  case "all stack files in a folder"
    set the loc of grp "folder" of stack "revSearch" to the cOnScreenLoc of grp "folder" of stack "revSearch"
    set the loc of grp "specific stack" of stack "revSearch" to the cOffScreenLoc of grp "specific stack" of stack "revSearch"
    set the text of fld "label" of stack "revSearch" to "Folder:"
    set the loc of fld "disabled" of stack "revSearch" to the cOffScreenLoc of fld "disabled" of stack "revSearch"
    enable fld "label" of stack "revSearch"
    select after text of fld "folder" of stack "revSearch"
    break
  default
    set the loc of grp "specific stack" of stack "revSearch" to the cOffScreenLoc of grp "specific stack" of stack "revSearch"
    set the loc of grp "folder" of stack "revSearch" to the cOffScreenLoc of grp "folder" of stack "revSearch"
    disable fld "label" of stack "revSearch"
    set the loc of fld "disabled" of stack "revSearch" to the cOnScreenLoc of fld "disabled" of stack "revSearch"
    break
  end switch
  unlock screen
end menuPick
