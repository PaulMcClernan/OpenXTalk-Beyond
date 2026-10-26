script "stack_Balloon_Game"
-- Stack file: ide/Resources/Examples/Remastered/Balloon Game.oxtstack
-- Object: stack "Balloon Game"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--Balloon Game: LiveCode Ltd's balloon ("Balloon Adventure"), remastered for OXT-Beyond in 2026
--balloon 1.0.0.0, LiveCode Ltd (then RunRev Ltd), 2013, made with LiveCode 6.1.1: the fourth sample of
--LiveCode Community's Start Center, free software under the GNU General Public License, version 3

--The game is on the cards "introduction", "page1", "page2", "page3" and "page4", the original's cards,
--each of which goes on to the next when you have done its task. Their scripts, and their controls',
--are the original's. The sidebar, the header and the drawer of scripts are the groups "Frame",
--"Workbench" and "Scripts", which the script of the group "Frame" runs.

on preOpenStack
   global gName
   ## (remaster) The window's list goes to any card: until you give your name, you are a pilot
   if gName is empty then
      put "pilot" into gName
   end if
   codeFont
end preOpenStack

## (remaster) The original's cards were 1024 by 768 pixels. The game is on the stage now, 744 pixels
## across, so it is drawn at 744/1024 of its size, and a place on the original's card is a place on
## the stage: stageLoc(85,655) is where the original put 85,655. The stage is not as tall as the card
## would be, so the top of the sky is cut off, and the ground stays at the bottom
constant kScale = 0.7265625

function stageLoc pX, pY
   return stageX(pX) & comma & stageY(pY)
end stageLoc

function stageX pX
   return the left of graphic "Stage" + round(pX * kScale)
end stageX

function stageY pY
   return the bottom of graphic "Stage" - round((768 - pY) * kScale)
end stageY

## A distance on the original's card, on the stage: a step of 25 pixels there is 18 here
function stageSize pPixels
   return max(1, round(pPixels * kScale))
end stageSize

## (remaster) The game's handlers name its pictures, which the engine looks for on the card in front of
## the default stack. A message sent in time (moveForeground) or at the end of a move (moveStopped)
## may come while another window is in front, the Script Editor if you are reading a script: the
## handler calls this first, so that the names are this stack's. The result is the stack that was
## the default one, to put back
command useGameStack
   local tStack
   put the defaultStack into tStack
   set the defaultStack to the short name of me
   return tStack
end useGameStack

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
