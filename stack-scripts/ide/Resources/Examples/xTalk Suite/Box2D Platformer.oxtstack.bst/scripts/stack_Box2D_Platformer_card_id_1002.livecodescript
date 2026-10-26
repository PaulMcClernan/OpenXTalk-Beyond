script "stack_Box2D_Platformer_card_id_1002"
-- Stack file: ide/Resources/Examples/xTalk Suite/Box2D Platformer.oxtstack
-- Object: stack "Box2D Platformer" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sCentered

on preOpenCard
   if sCentered is not true then
      put true into sCentered
      set the loc of this stack to the screenLoc
   end if
   pass preOpenCard
end preOpenCard

on closeStack
   put empty into sCentered
   pass closeStack
end closeStack
