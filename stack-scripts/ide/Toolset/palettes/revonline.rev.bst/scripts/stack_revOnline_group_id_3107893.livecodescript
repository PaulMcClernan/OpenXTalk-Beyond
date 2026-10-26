script "stack_revOnline_group_id_3107893"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "image importer" (id 3107893)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command hideMe
   send "hidepalette" to the owner of me in 0 milliseconds
end hideMe

constant kMoveInterval = 3
constant kIncreaseScaleFactor = 1.1
constant kDecreaseScaleFactor = 0.9

command moveUp
   if the visible of group "stack crop box" of me then
      set the top of image "stack image import" of me to the top of image "stack image import" of me + kMoveInterval
   else
      set the top of image "user image import" of me to the top of image "user image import" of me + kMoveInterval
   end if
end moveUp

command moveDown
    if the visible of group "stack crop box" of me then
      set the top of image "stack image import" of me to the top of image "stack image import" of me - kMoveInterval
   else
      set the top of image "user image import" of me to the top of image "user image import" of me - kMoveInterval
   end if
end moveDown

command moveRight
   if the visible of group "stack crop box" of me then
      set the right of image "stack image import" of me to the right of image "stack image import" of me - kMoveInterval
   else
      set the right of image "user image import" of me to the right of image "user image import" of me - kMoveInterval
   end if
end moveRight

command moveLeft
   if the visible of group "stack crop box" of me then
      set the right of image "stack image import" of me to the right of image "stack image import" of me + kMoveInterval
   else
      set the right of image "user image import" of me to the right of image "user image import" of me + kMoveInterval
   end if
end moveLeft

command zoomIn
   lock screen
   if the visible of group "stack crop box" of me then
      set the height of image "stack image import" of me to (the height of image "stack image import" of me * kIncreaseScaleFactor)
      set the width of image "stack image import" of me to (the width of image "stack image import" of me * kIncreaseScaleFactor)
      --set the loc of image "stack image import" of me to the loc of group "stack crop box" of me
   else
      set the height of image "user image import" of me to (the height of image "user image import" of me * kIncreaseScaleFactor)
      set the width of image "user image import" of me to (the width of image "user image import" of me * kIncreaseScaleFactor)
      --set the loc of image "user image import" of me to the loc of group "user crop box" of me
   end if
   unlock screen
end zoomIn

command zoomOut
   lock screen
   if the visible of group "stack crop box" of me then
      set the height of image "stack image import" of me to (the height of image "stack image import" of me * kDecreaseScaleFactor)
      set the width of image "stack image import" of me to (the width of image "stack image import" of me * kDecreaseScaleFactor)
      set the loc of image "stack image import" of me to the loc of group "stack crop box" of me
   else
      set the height of image "user image import" of me to (the height of image "user image import" of me * kDecreaseScaleFactor)
      set the width of image "user image import" of me to (the width of image "user image import" of me * kDecreaseScaleFactor)
      set the loc of image "user image import" of me to the loc of group "user crop box" of me
   end if
   unlock screen
end zoomOut

command resetImage
   lock screen
   if the visible of group "stack crop box" of me then
      set the rect of image "stack image import" of me to the rect of group "stack crop box" of me
   else
      set the rect of image "user image import" of me to the rect of group "user crop box" of me
   end if
   unlock screen
end resetImage

command submitImage
   send "takeSnapshot" to the owner of me in 0 milliseconds
end submitImage
