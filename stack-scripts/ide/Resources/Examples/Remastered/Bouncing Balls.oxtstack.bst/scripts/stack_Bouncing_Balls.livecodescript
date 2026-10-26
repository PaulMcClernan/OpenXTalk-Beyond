script "stack_Bouncing_Balls"
-- Stack file: ide/Resources/Examples/Remastered/Bouncing Balls.oxtstack
-- Object: stack "Bouncing Balls"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--Bouncing Balls: LiveCode Ltd's Balls ("Bouncing balls"), remastered for OXT-Beyond in 2026
--Balls 1.0.0.0, LiveCode Ltd (then RunRev Ltd), 2011: the first sample of LiveCode Community's Start Center,
--free software under the GNU General Public License, version 3

--The program is on the card "Main": the script of the card is the main loop, and the script of the
--button "bounce" (Bounce Behavior) is every ball's behavior. The sidebar, the header and the drawer of
--scripts are the groups "Frame", "Workbench" and "Scripts", which the script of the group "Frame" runs.

on preOpenStack
   ## Turn on acceleratedRendering
   ## (remaster) The checkbox is on the card "Main", and is a switch: it shows that it is on
   set the hilited of button "toggleGraphics" of card "Main" of me to true
   dispatch "showSwitch" to button "toggleGraphics" of card "Main" of me
   graphicsToggle
   set the randomSeed to 109871234
   if the environment is "mobile" then
      ## (remaster) The original hid group 1, its Simulate Shake and Bounce Behavior buttons: a phone
      ## shakes for real. Group 1 is the window's sidebar now, so the button is named
      set the visible of group "Simulate Shake" of card "Main" of me to false
      mobileSetAllowedOrientations "portrait,portrait upside down,landscape left,landscape right"
   end if
   if the platform is "iphone" then
      iphoneUseDeviceResolution true
   end if
   codeFont
end preOpenStack

## (remaster) The code on the pages is in Source Code Pro, which the IDE has. Where the fontNames
## have not got it (the web IDE, and Linux, which leaves out a font loaded from a file), it is in the
## first monospaced font there is, as the scripts in the drawer are
command codeFont
   local tError, tFont, tCard, tField
   if the environment is "development" then
      ## The IDE keeps Source Code Pro for its Script Editor, and Droid Sans Mono for its Dictionary
      try
         if "Source Code Pro" is not among the lines of the fontNames then
            start using font file (revIDESpecialFolderPath("fonts") & "/SourceCodePro-Regular.ttf")
         end if
      catch tError
      end try
      try
         if "Source Code Pro" is not among the lines of the fontNames and \
               "Droid Sans Mono" is not among the lines of the fontNames then
            start using font file (revIDESpecialFolderPath("IDE") & "/Documentation/html_viewer/resources/data/api/DroidSansMono.ttf")
         end if
      catch tError
      end try
   end if
   repeat for each item tFont in "Source Code Pro,Droid Sans Mono,Menlo,Consolas,DejaVu Sans Mono,Courier New"
      if tFont is among the lines of the fontNames then
         repeat with tCard = 1 to the number of cards of me
            repeat with tField = 1 to the number of fields of card tCard of me
               if the cCode of field tField of card tCard of me is true and \
                     the textFont of field tField of card tCard of me is not tFont then
                  set the textFont of field tField of card tCard of me to tFont
               end if
            end repeat
         end repeat
         exit repeat
      end if
   end repeat
end codeFont

## Toggle between the compositor being on or off.
## This is the important part of the new accelerated graphics.  Using the compositor
## will mean that the stack's background is split up into tiles and cached.
## The "dynamic" balls will bounce around the screen, obscuring tiles.  Only the
## obscured tiles will be redrawn.  When the ball leaves a tile, the cached
## tile will be redrawn again, but this time using the cached information.

## On MacOS we use the CoreGraphics compositor, on iOS the OpenGL compositor.
## On all other platforms we use the software compositor.

## Play around the compositor settings to see how they effect performance
## on your platform.
on graphicsToggle
   set the acceleratedrendering of me to the hilited of button "toggleGraphics" of card "Main" of me
end graphicsToggle
