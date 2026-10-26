script "stack_balloon_button_id_1019"
-- Stack file: ide/Resources/Start Center/samples/sample_4/balloon.livecode
-- Object: stack "balloon" > card "introduction" (id 1002) > button "start" (id 1019)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## The mouseUp messgae is sent by LiveCode when the user clicks and releases on a control
on mouseUp
   ## Use a global variable to store the user's name
   global gName
   
   ## The ask command displays a native dialog with a box the user can type into to answer
   ask "What is your name?"
   
   ## If the user does not cancel the dialog
   if the result is not "cancel" then
      ## Their answer is returned in the special variable "it"
      ## Put the answer into the global variable gName
      put it into gName
      ## Move to the next card
      go to the next card
   end if
end mouseUp
