script "stack_Mobile_Scroller_Example_card_id_1002"
-- Stack file: ide/Resources/Mobile Examples/Scroller Example.livecode
-- Object: stack "Mobile Scroller Example" > card "Main" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sScrollerId

on preOpenCard
   if the environment is not "mobile" then
      exit preOpenCard
   end if
   
   -- Turn on 'out-of-bounds' scrolling for our image group
   set the unboundedHScroll of group "Image Scroller" to true
   set the unboundedVScroll of group "Image Scroller" to true
   
   -- Create the scroller and store its id
   iphoneControlCreate "scroller"
   put the result into sScrollerId
   
   -- The 'rect' is the region of the card it should cover
   iphoneControlSet sScrollerId, "rect", the rect of group "Image Scroller"
   -- The 'contentRect' is the region the scroller scrolls over
   iphoneControlSet sScrollerId, "contentRect", (0, 0, 1600, 1200)
   -- The 'visible' determines if the scroller is displayed
   iphoneControlSet sScrollerId, "visible", "true"
   -- The 'canBounce' determines whether the standard iOS 'bouncing' occurs
   -- at extremities of scrolling
   iphoneControlSet sScrollerId, "canBounce", "false"
   -- The 'pagingEnabled' determines whether scrolling only happens in multiples
   -- of the width/height
   iphoneControlSet sScrollerId, "pagingEnabled", "false"
   -- The 'canScrollToTop' determines whether touching the status bar scrolls
   -- the scroller to the top
   iphoneControlSet sScrollerId, "canScrollToTop", "true"
   
   -- Make sure we are the right size for display
   resizeStack
end preOpenCard

on closeCard
   if the environment is not "mobile" then
      exit closeCard
   end if
   
   iphoneControlDelete sScrollerId
end closeCard

on resizeStack
   if the environment is not "mobile" then
      exit resizeStack
   end if
   
   -- Reset the scroll to 0
   set the hScroll of group "Image Scroller" to 0
   set the vScroll of group "Image Scroller" to 0
   
   -- Layout the card
   set the rect of group "Image Scroller" to the left of this card + 4, the top of this card + 4, the right of this card - 4, the bottom of this card - 36
   set the topLeft of image "Image 1" to the topLeft of group "Image Scroller"
   set the topLeft of image "Image 2" to the topRight of image "Image 1"
   set the topLeft of image "Image 3" to the bottomLeft of image "Image 1"
   set the topLeft of image "Image 4" to the bottomRight of image "Image 1"
   set the loc of group "Controls" to item 1 of the loc of this card, the bottom of this card - 18
   
   -- Update the scroller properties
   iphoneControlSet sScrollerId, "rect", the rect of group "Image Scroller"
   iphoneControlSet sScrollerId, "hscroll", 0
   iphoneControlSet sScrollerId, "vscroll", 0
end resizeStack

on scrollerDidScroll pOffsetX, pOffsetY
   -- Set the scroll values of the group based on feedback from the scroller
   -- notice that we can just use the values directly and because out-of-bounds
   -- scrolling is enabled for the group, the bounce effect needs no extra
   -- code.
   lock screen
   set the hScroll of group "Image Scroller" to pOffsetX
   set the vScroll of group "Image Scroller" to pOffsetY
   unlock screen
   
   put pOffsetX, pOffsetY into field "Offsets"
end scrollerDidScroll

on doAction pAction
   iphoneControlDo sScrollerId, pAction
end doAction

on doSetProp pProp, pValue
   iphoneControlSet sScrollerId, pProp, pValue
end doSetProp

on errorDialog
   write the params to stderr
end errorDialog
