script "stack_Torrent_Client_card_id_1002"
-- Stack file: ide/Resources/Examples/xTalk Suite/Torrent Client.oxtstack
-- Object: stack "Torrent Client" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sCentered

on preOpenCard
   if sCentered is not true then
      put true into sCentered
      if the uHeight of this stack is a number and the uHeight of this stack >= 500 then
         set the height of this stack to (the uHeight of this stack)
      end if
      if the uSavePath of this stack is not empty then
         put the uSavePath of this stack into field "tcSavePath"
      else
         put tcDefaultSavePath() into field "tcSavePath"
      end if
      if the uUpLimit of this stack is not empty then
         put the uUpLimit of this stack into field "tcUpLimit"
      else
         put "0" into field "tcUpLimit"
      end if
      set the loc of this stack to the screenLoc
   end if
   pass preOpenCard
end preOpenCard

on closeStack
   put empty into sCentered
   pass closeStack
end closeStack
