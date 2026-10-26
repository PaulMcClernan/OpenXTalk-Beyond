script "stack_Balloon_Game_button_id_1213"
-- Stack file: ide/Resources/Examples/Remastered/Balloon Game.oxtstack
-- Object: stack "Balloon Game" > card "introduction" (id 1031) > group "Scene" (id 1210) > button "start" (id 1213)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## The mouseUp message is sent by the engine when the user clicks and releases on a control
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
      ## (remaster) No name is no matter: the game calls you pilot
      if gName is empty then
         put "pilot" into gName
      end if
      ## Move to the next card
      go to the next card
   end if
end mouseUp
