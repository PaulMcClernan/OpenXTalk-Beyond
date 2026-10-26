script "stack_Balls"
-- Stack file: ide/Resources/Start Center/samples/sample_1/Balls.livecode
-- Object: stack "Balls"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   ## Turn on acceleratedRendering
   set the hilited of button "toggleGraphics" of card "Main" of me to true
   graphicsToggle
   set the randomSeed to 109871234
   if the environment is "mobile" then
      set the visible of group 1 to false
      mobileSetAllowedOrientations "portrait,portrait upside down,landscape left,landscape right"
   end if
   if the platform is "iphone" then
      iphoneUseDeviceResolution true
   end if
end preOpenStack

## Toggle between the compositor being on or off.
## This is the important part of the new accelerated graphics.  Using the compsitor
## will mean that the stack's background is split up into tiles and cached.
## The "dynamic" balls will bounce around the screen, obscuring tiles.  Only the
## obscured tiles will be redrawn.  When the ball leaves a tile, the cached
## tile will be redrawn again, but this time using the cached information.

## On MacOS we use the CoreGraphics compositor, on iOS the OpenGL compositor.
## On all othe platforms we use the software compositor.

## Play around the compositor settings to see how they effect performance
## on your platform.
on graphicsToggle
   set the acceleratedrendering of me to the hilited of button "toggleGraphics" of card "Main" of me
end graphicsToggle
