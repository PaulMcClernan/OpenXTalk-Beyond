script "stack_revGettingStartedScripts_button_id_1078"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Check whether a directory or drive is write-protected Example" (id 1077) > button "Check a directory..." (id 1078)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer folder "Please choose a folder:"
  if it is empty then exit mouseUp -- no folder chosen
  if canWriteFileTo(it) then answer it & return & "can be written to."
  else answer it & return & "is write-locked."
end mouseUp

function canWriteFileTo theLocation
  put theLocation & "/temp" & random(9999) into randomFileName
  open file randomFileName for write -- try creating a file
  if the result is empty then -- success!
    close file randomFileName
    delete file randomFileName -- get rid of the test file
    return true
  else -- failed - couldn't create a file there
    return false
  end if
end canWriteFileTo
