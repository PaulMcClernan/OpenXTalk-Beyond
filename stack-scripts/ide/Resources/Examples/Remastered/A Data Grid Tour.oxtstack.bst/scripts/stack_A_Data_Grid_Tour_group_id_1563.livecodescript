script "stack_A_Data_Grid_Tour_group_id_1563"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > card "The Template" (id 1036) > group "Replay" (id 1563)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --added: the rows arrive again, as when the card opens
   local tMessage
   repeat for each line tMessage in the pendingMessages
      if item 3 of tMessage is "demonstrationStart" then cancel item 1 of tMessage
   end repeat
   dispatch "openCard" to this card  --(dispatch, as the card passes openCard on: a send would end in an error)
end mouseUp
