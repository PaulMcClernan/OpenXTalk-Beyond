script "CoreInterfaceShowCards"
/*
Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond, a fork of LiveCode Community.

LiveCode is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

LiveCode is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with LiveCode.  If not see <http://www.gnu.org/licenses/>.  */

-- OXT-Beyond: tests of "show <number> cards", "show all cards" and "show
-- marked cards", which go through that many cards of the defaultStack
-- (MCStack::flip in engine/src/stack3.cpp). A count of 0 ended the
-- engine, and "show 0 cards", "show -1 cards" (the number -1 is 0 cards),
-- "show 65536 cards" (the count has 16 bits), an empty count and "show
-- marked cards" with no card marked all ask for it (openxtalk.org
-- p=25427). Now no card is shown and the handler goes on. Every other
-- count goes through the cards as it did, which the other tests hold.

constant kStack = "CoreInterfaceShowCardsStack"

-- The short names of the cards opened, from the stack's openCard
global gCoreInterfaceShowCardsLog

on TestSetup
   local tCard
   create stack kStack
   set the defaultStack to kStack
   repeat 4 times
      create card
   end repeat
   repeat with tCard = 1 to 5
      set the name of card tCard of stack kStack to "c" & tCard
   end repeat
   set the script of stack kStack to \
         "global gCoreInterfaceShowCardsLog" & return & \
         "on openCard" & return & \
         "put the short name of the target & space after gCoreInterfaceShowCardsLog" & return & \
         "end openCard"
end TestSetup

on TestTearDown
   delete stack kStack
end TestTearDown

-- Each test calls this first: the runner dispatches each handler to the
-- test's stack, which makes that stack the defaultStack for it
private command _TestGoToCard pCard
   set the defaultStack to kStack
   go card pCard of stack kStack
   put empty into gCoreInterfaceShowCardsLog
end _TestGoToCard

private function _TestThisCard
   return the short name of this card of stack kStack
end _TestThisCard

private function _TestCardsOpened
   return word 1 to -1 of gCoreInterfaceShowCardsLog
end _TestCardsOpened

on TestShowCards
   _TestGoToCard 1
   show 2 cards
   TestAssert "show 2 cards goes from card 1 to card 3", _TestThisCard() is "c3"
   TestAssert "show 2 cards opens cards 2 and 3", _TestCardsOpened() is "c2 c3"

   _TestGoToCard 4
   show 3 cards
   TestAssert "show 3 cards from card 4 goes on from card 1", _TestThisCard() is "c2"
   TestAssert "show 3 cards from card 4 opens cards 5, 1 and 2", \
         _TestCardsOpened() is "c5 c1 c2"

   _TestGoToCard 1
   show 5 cards
   TestAssert "show 5 cards of 5 comes back to the card", _TestThisCard() is "c1"
   TestAssert "show 5 cards of 5 opens each card", \
         _TestCardsOpened() is "c2 c3 c4 c5 c1"

   -- The count has 16 bits, as before
   _TestGoToCard 1
   show 65537 cards
   TestAssert "show 65537 cards shows one card", _TestThisCard() is "c2"
end TestShowCards

on TestShowZeroCards
   local tError
   _TestGoToCard 2
   try
      show 0 cards
   catch tError
   end try
   TestAssert "show 0 cards is not an error", tError is empty
   TestAssert "show 0 cards stays on the card", _TestThisCard() is "c2"
   TestAssert "show 0 cards opens no card", _TestCardsOpened() is empty
   show 1 card
   TestAssert "show 1 card after show 0 cards goes to the next card", \
         _TestThisCard() is "c3"
end TestShowZeroCards

on TestShowNegativeCards
   local tError, tCount
   _TestGoToCard 1
   try
      show -1 cards
   catch tError
   end try
   TestAssert "show -1 cards is not an error", tError is empty
   TestAssert "show -1 cards stays on the card", _TestThisCard() is "c1"
   TestAssert "show -1 cards opens no card", _TestCardsOpened() is empty

   put 0 - 5 into tCount
   try
      show tCount cards
   catch tError
   end try
   TestAssert "show -5 cards is not an error", tError is empty
   TestAssert "show -5 cards stays on the card", _TestThisCard() is "c1"
   TestAssert "show -5 cards opens no card", _TestCardsOpened() is empty
   show 1 card
   TestAssert "show 1 card after show -5 cards goes to the next card", \
         _TestThisCard() is "c2"
end TestShowNegativeCards

on TestShowCardsCountOf65536
   local tError
   _TestGoToCard 1
   try
      show 65536 cards
   catch tError
   end try
   TestAssert "show 65536 cards is not an error", tError is empty
   TestAssert "show 65536 cards stays on the card", _TestThisCard() is "c1"
   TestAssert "show 65536 cards opens no card", _TestCardsOpened() is empty
   show 1 card
   TestAssert "show 1 card after show 65536 cards goes to the next card", \
         _TestThisCard() is "c2"
end TestShowCardsCountOf65536

on TestShowEmptyCards
   local tError, tCount
   _TestGoToCard 1
   put empty into tCount
   try
      show tCount cards
   catch tError
   end try
   TestAssert "show cards with an empty count is not an error", tError is empty
   TestAssert "show cards with an empty count stays on the card", \
         _TestThisCard() is "c1"
   TestAssert "show cards with an empty count opens no card", \
         _TestCardsOpened() is empty
   show 1 card
   TestAssert "show 1 card after an empty count goes to the next card", \
         _TestThisCard() is "c2"
end TestShowEmptyCards

on TestShowCardsNotANumber
   local tError
   _TestGoToCard 1
   try
      show "abc" cards
   catch tError
   end try
   TestAssert "show abc cards is an error", tError is not empty
   TestAssert "show abc cards stays on the card", _TestThisCard() is "c1"
   TestAssert "show abc cards opens no card", _TestCardsOpened() is empty
end TestShowCardsNotANumber

on TestShowAllCards
   _TestGoToCard 3
   show all cards
   TestAssert "show all cards comes back to the card", _TestThisCard() is "c3"
   TestAssert "show all cards opens each card", \
         _TestCardsOpened() is "c4 c5 c1 c2 c3"
end TestShowAllCards

on TestShowMarkedCards
   _TestGoToCard 1
   set the mark of card "c4" of stack kStack to true
   show marked cards
   TestAssert "show marked cards goes to the marked card", _TestThisCard() is "c4"
   TestAssert "show marked cards opens the marked card", _TestCardsOpened() is "c4"

   set the mark of card "c2" of stack kStack to true
   _TestGoToCard 1
   show marked cards
   TestAssert "show marked cards goes through two marked cards", \
         _TestThisCard() is "c4"
   TestAssert "show marked cards opens the two marked cards", \
         _TestCardsOpened() is "c2 c4"
   TestAssert "show marked cards leaves the cards marked", \
         the mark of card "c2" of stack kStack and \
         the mark of card "c4" of stack kStack and \
         not the mark of card "c1" of stack kStack
end TestShowMarkedCards

on TestShowMarkedCardsNoneMarked
   local tError
   _TestGoToCard 2
   try
      show marked cards
   catch tError
   end try
   TestAssert "show marked cards with none marked is not an error", tError is empty
   TestAssert "show marked cards with none marked stays on the card", \
         _TestThisCard() is "c2"
   TestAssert "show marked cards with none marked opens no card", \
         _TestCardsOpened() is empty
   show 1 card
   TestAssert "show 1 card after show marked cards with none marked goes to the next card", \
         _TestThisCard() is "c3"
end TestShowMarkedCardsNoneMarked
