script "stack_revGettingStartedScripts_button_id_1094"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Converting a relative path to an absolute path Example" (id 1092) > button "Convert Path" (id 1094)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer absolutePath(field "Path",field "Starting Folder")
end mouseUp

function absolutePath relativePath,startingFolder
  -- make sure this is a relative path:
  if (the platform is "Win32" \
     and char 2 of relativePath is ":") \
     or (char 1 of relativePath is "/") then
    return "Error: path is not a relative path"
  end if
  -- use the current folder as the starting folder by default:
  if startingFolder is empty
  then put the defaultFolder into startingFolder
  if last char of startingFolder is "/"
  then delete last char of startingFolder
  set the itemDelimiter to "/"
  if first item of relativePath is "."
  then delete first item of relativePath
  -- move up one folder for each ".." in the relative path:
  repeat while first item of relativePath is ".."
    delete first item of relativePath -- done with it
    delete last item of startingFolder -- go up one folder
    if startingFolder is empty then
      -- there were too many ".." in the relative path
      return "Error: relative path has too many components"
    end if
  end repeat
  return startingFolder & "/" & relativePath
end absolutePath
