script "stack_revGettingStartedScripts_button_id_1103"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Converting an absolute path to a relative path Example" (id 1101) > button "Convert Path" (id 1103)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer relativePath(field "Path",field "Starting Folder")
end mouseUp

function relativePath absolutePath,startingFolder
  -- make sure this is an absolute path:
  if (the platform is "Win32" and \
      (char 1 of absolutePath is not in \
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ" \
      or char 2 of absolutePath is not ":")) \
      or (the platform is not "Win32" and \
      char 1 of absolutePath is not "/") then
    return "Error: path is not an absolute path"
  end if
  -- use the current folder as the starting folder by default:
  if startingFolder is empty
  then put the defaultFolder into startingFolder
  if absolutePath is startingFolder then return "."
  set the itemDelimiter to "/"
  repeat
    if item 1 of startingFolder is item 1 of absolutePath
    then -- theyre in the same disk or folder
      delete item 1 of absolutePath
      delete item 1 of startingFolder
    else exit repeat
  end repeat
  repeat for (the number of items in startingFolder) times
    put "../" before absolutePath
  end repeat
  return absolutePath -- now changed to a relative path
end relativePath
