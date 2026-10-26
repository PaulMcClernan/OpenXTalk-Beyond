script "stack_balloon_image_id_1015"
-- Stack file: ide/Resources/Start Center/samples/sample_4/balloon.livecode
-- Object: stack "balloon" > card "page1" (id 1012) > image "balloon" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

## The mouseUp messgae is sent by LiveCode when the user clicks and releases on a control
on mouseUp
   ## The move command moves an object smoothly along a path
   move image "balloon" to the points of graphic "path" in 3 seconds without waiting
end mouseUp

## The moveStopped message is sent when a "move" command finishes
on moveStopped
   ## Balloon has been piloted off the right side of the screen
   ## Position the balloon on the next card so it follows
   set the top of image "balloon" of card "page2" to the top of image "balloon" of this card
   set the left of image "balloon" of card "page2" to 0
   ## Go to the next card
   go next card
end moveStopped
