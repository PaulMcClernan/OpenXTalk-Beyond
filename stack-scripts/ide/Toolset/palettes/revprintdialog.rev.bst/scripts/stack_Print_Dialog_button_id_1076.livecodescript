script "stack_Print_Dialog_button_id_1076"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002) > group "Print Target" (id 1442) > button "Browse" (id 1076)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tFile
  ask file "Please choose file to print to" with type outputFileType(the platform)
  put it into tFile
  if tFile is empty then
    exit mouseUp
  end if
  
  put tFile into field "Filename"
end mouseUp

function outputFileType pPlatform
  switch pPlatform
  case "win32"
    return "All files|*|"
    break
  case "macos"
    return "PDF files|PDF|"
    break
  case "linux"
    return "PostScript files|PS|"
    break
  end switch
end outputFileType

