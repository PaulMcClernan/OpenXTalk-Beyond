script "stack_Balloon_Game_image_id_1222"
-- Stack file: ide/Resources/Examples/Remastered/Balloon Game.oxtstack
-- Object: stack "Balloon Game" > card "page1" (id 1032) > group "Scene" (id 1218) > image "balloon" (id 1222)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## The mouseUp message is sent by the engine when the user clicks and releases on a control
on mouseUp
   ## The move command moves an object smoothly along a path
   move image "balloon" to the points of graphic "path" in 3 seconds without waiting
end mouseUp

## The moveStopped message is sent when a "move" command finishes
on moveStopped
   ## (remaster) The move ends 3 seconds after the click, whichever window is in front then:
   ## useGameStack, in the script of the stack, makes the names below this stack's
   useGameStack
   ## Balloon has been piloted off the right side of the screen
   ## Position the balloon on the next card so it follows
   set the top of image "balloon" of card "page2" to the top of image "balloon" of this card
   ## (remaster) at the left of the stage, as the original's was at the left of its card, 0, and a
   ## step in, so that the stage's edge does not cut off its side
   set the left of image "balloon" of card "page2" to the left of graphic "Stage" + stageSize(16)
   ## Go to the next card
   go next card
end moveStopped
