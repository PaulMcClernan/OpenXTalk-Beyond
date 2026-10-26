script "CoreEngineHyperTalkCompatible"
/*
OXT-Beyond: the hyperTalkCompatible of a stack, which File > Import Stack
sets for a stack imported from HyperCard. Off, every message goes where
it always went; on, a background part's message reaches the card before
the background, a handler can be called doMenu, and doMenu is a message
before it runs, even while messages are locked, as in HyperCard; and
lockRecent keeps no card of the stack out of the recent cards that go
back goes through. Each test checks the stack with the property off too.
*/

local sStack

-- A stack whose card, background group and stack each log the message
-- "hcOrder" and pass it; a button "B" in the background, a button "C" on
-- the card
private command _MakeStack pCompatible
   local tLogger
   put "HyperTalk" & the milliseconds & random(100000) into sStack
   create invisible stack sStack
   set the defaultStack to sStack
   if pCompatible then set the hyperTalkCompatible of stack sStack to true
   create group "BG"
   set the backgroundBehavior of group "BG" to true
   create button "B" in group "BG"
   create button "C"
   put "on hcOrder" & return & "global gHCOrder" & return \
         & "put the short name of me & comma after gHCOrder" & return \
         & "pass hcOrder" & return & "end hcOrder" into tLogger
   set the script of group "BG" of stack sStack to tLogger
   set the script of card 1 of stack sStack to tLogger
   set the script of stack sStack to tLogger
end _MakeStack

private command _DeleteStack
   if there is a stack sStack then delete stack sStack
end _DeleteStack

private function _Order pObject
   global gHCOrder
   put empty into gHCOrder
   send "hcOrder" to pObject
   return gHCOrder
end _Order

on TestHyperTalkCompatibleProperty
   local tProps
   create invisible stack "HyperTalkDefault"
   TestAssert "a new stack's hyperTalkCompatible is false", \
         the hyperTalkCompatible of stack "HyperTalkDefault" is false
   set the hyperTalkCompatible of stack "HyperTalkDefault" to true
   TestAssert "it can be set", the hyperTalkCompatible of stack "HyperTalkDefault" is true
   put the customProperties of stack "HyperTalkDefault" into tProps
   TestAssert "the stack keeps it as a custom property", tProps["hyperTalkCompatible"] is true
   set the hyperTalkCompatible of stack "HyperTalkDefault" to false
   TestAssert "and turned off", the hyperTalkCompatible of stack "HyperTalkDefault" is false
   delete stack "HyperTalkDefault"
end TestHyperTalkCompatibleProperty

on TestHyperTalkCompatibleBackgroundOrderOff
   _MakeStack false
   TestAssert "off: a background part's message goes to the background, then the card", \
         _Order(the long id of button "B" of stack sStack) is "BG," & the short name of card 1 of stack sStack & "," & sStack & ","
   TestAssert "off: the background's own message", \
         _Order(the long id of group "BG" of stack sStack) is "BG," & the short name of card 1 of stack sStack & "," & sStack & ","
   TestAssert "off: a card part's message", \
         _Order(the long id of button "C" of stack sStack) is the short name of card 1 of stack sStack & ",BG," & sStack & ","
   _DeleteStack
end TestHyperTalkCompatibleBackgroundOrderOff

on TestHyperTalkCompatibleBackgroundOrder
   _MakeStack true
   TestAssert "on: a background part's message goes to the card, then the background", \
         _Order(the long id of button "B" of stack sStack) is the short name of card 1 of stack sStack & ",BG," & sStack & ","
   TestAssert "on: the background's own message is as before", \
         _Order(the long id of group "BG" of stack sStack) is "BG," & the short name of card 1 of stack sStack & "," & sStack & ","
   TestAssert "on: a card part's message is as before", \
         _Order(the long id of button "C" of stack sStack) is the short name of card 1 of stack sStack & ",BG," & sStack & ","

   -- a card handler that does not pass keeps the message from the background
   set the script of card 1 of stack sStack to "on hcOrder" & return & "global gHCOrder" & return \
         & "put " & quote & "card only," & quote & " after gHCOrder" & return & "end hcOrder"
   TestAssert "on: the card can keep the message from the background", \
         _Order(the long id of button "B" of stack sStack) is "card only,"
   _DeleteStack
end TestHyperTalkCompatibleBackgroundOrder

on TestHyperTalkCompatibleDoMenuOff
   global gHCOrder
   _MakeStack false
   set the script of card 1 of stack sStack to "on doMenu pItem" & return & "end doMenu"
   TestAssert "off: no handler can be called doMenu", the result is not empty

   set the script of button "C" of stack sStack to "on mouseUp" & return & "global gHCOrder" & return \
         & "doMenu " & quote & "Not An Item" & quote & return & "put the result into gHCOrder" & return & "end mouseUp"
   put empty into gHCOrder
   send "mouseUp" to button "C" of stack sStack
   TestAssert "off: doMenu runs the menu item", gHCOrder contains "not implemented"

   set the script of button "C" of stack sStack to "on mouseUp" & return & "global gHCOrder" & return \
         & "lock messages" & return & "doMenu " & quote & "Not An Item" & quote & return \
         & "put the result into gHCOrder" & return & "unlock messages" & return & "end mouseUp"
   put empty into gHCOrder
   send "mouseUp" to button "C" of stack sStack
   TestAssert "off: and the same with messages locked", gHCOrder contains "not implemented"
   _DeleteStack
end TestHyperTalkCompatibleDoMenuOff

on TestHyperTalkCompatibleDoMenu
   global gHCOrder, gHCResult
   _MakeStack true
   set the script of card 1 of stack sStack to "on doMenu pItem" & return & "global gHCOrder" & return \
         & "put pItem after gHCOrder" & return & "if pItem is " & quote & "Pass Me" & quote & " then pass doMenu" & return \
         & "end doMenu"
   TestAssert "on: a handler can be called doMenu", the result is empty

   set the script of button "C" of stack sStack to "on mouseUp pItem" & return & "global gHCResult" & return \
         & "doMenu pItem" & return & "put the result into gHCResult" & return & "end mouseUp"
   put empty into gHCOrder
   put empty into gHCResult
   send "mouseUp" && quote & "Not An Item" & quote to button "C" of stack sStack
   TestAssert "on: doMenu reaches the card's doMenu handler", gHCOrder is "Not An Item"
   TestAssert "on: which takes it, so no menu item runs", gHCResult is empty

   put empty into gHCOrder
   send "mouseUp" && quote & "Pass Me" & quote to button "C" of stack sStack
   TestAssert "on: a handler that passes doMenu sees it", gHCOrder is "Pass Me"
   TestAssert "on: and the menu item runs after it", gHCResult contains "not implemented"
   _DeleteStack
end TestHyperTalkCompatibleDoMenu

-- HyperCard's lockMessages kept back only its own messages (openCard,
-- closeCard...), so a doMenu handler saw the items a script chose with
-- them locked, and ran with them still locked
on TestHyperTalkCompatibleDoMenuLocked
   global gHCOrder, gHCResult, gHCLocked
   _MakeStack true
   set the script of card 1 of stack sStack to "on doMenu pItem" & return & "global gHCOrder" & return \
         & "put pItem & comma & the lockMessages after gHCOrder" & return \
         & "if pItem is " & quote & "Pass Me" & quote & " then pass doMenu" & return \
         & "end doMenu"
   set the script of button "C" of stack sStack to "on mouseUp pItem" & return \
         & "global gHCResult, gHCLocked" & return & "lock messages" & return & "doMenu pItem" & return \
         & "put the result into gHCResult" & return & "put the lockMessages into gHCLocked" & return \
         & "unlock messages" & return & "end mouseUp"
   put empty into gHCOrder
   put empty into gHCResult
   put empty into gHCLocked
   send "mouseUp" && quote & "Not An Item" & quote to button "C" of stack sStack
   TestAssert "on: with messages locked, doMenu still reaches the card's doMenu handler", \
         item 1 of gHCOrder is "Not An Item"
   TestAssert "on: which runs with messages still locked", item 2 of gHCOrder is true
   TestAssert "on: and takes it, so no menu item runs", gHCResult is empty
   TestAssert "on: messages are still locked after it", gHCLocked is true

   put empty into gHCOrder
   send "mouseUp" && quote & "Pass Me" & quote to button "C" of stack sStack
   TestAssert "on: with messages locked, a handler that passes doMenu sees it", gHCOrder is "Pass Me,true"
   TestAssert "on: and the menu item runs after it", gHCResult contains "not implemented"
   _DeleteStack
end TestHyperTalkCompatibleDoMenuLocked

-- Three cards, "one", "two" and "three"; then card "three" and card
-- "one" visited, then card "two" with the lockRecent true, and go back:
-- the short name of the card it goes to, and the lockRecent after it
private function _GoBackAfterLockRecent
   local tCard, tLocked
   set the defaultStack to sStack
   create card
   create card
   set the name of card 1 of stack sStack to "one"
   set the name of card 2 of stack sStack to "two"
   set the name of card 3 of stack sStack to "three"
   go to card "three" of stack sStack
   go to card "one" of stack sStack
   set the lockRecent to true
   go to card "two" of stack sStack
   go back
   put the short name of this card of stack sStack into tCard
   put the lockRecent into tLocked
   set the lockRecent to false
   return tCard & comma & tLocked
end _GoBackAfterLockRecent

on TestHyperTalkCompatibleGoBackOff
   _MakeStack false
   -- (the recent cards are those of stacks open as a window of their own)
   if the mode of stack sStack is not 1 then
      TestSkip "off: go back after the lockRecent", "the stack is not open as a window of its own"
   else
      TestAssert "off: a card visited with the lockRecent true is not in the recent cards, so go back passes over it", \
            _GoBackAfterLockRecent() is "three,true"
   end if
   _DeleteStack
end TestHyperTalkCompatibleGoBackOff

-- HyperCard's lockRecent kept cards out of the Recent dialog's pictures
-- only: go back still went back through every card visited
on TestHyperTalkCompatibleGoBack
   _MakeStack true
   if the mode of stack sStack is not 1 then
      TestSkip "on: go back after the lockRecent", "the stack is not open as a window of its own"
   else
      TestAssert "on: go back goes to the card before, though it was visited with the lockRecent true", \
            _GoBackAfterLockRecent() is "one,true"
   end if
   _DeleteStack
end TestHyperTalkCompatibleGoBack

on TestHyperTalkCompatibleSubstack
   _MakeStack true
   create invisible stack "HyperTalkSub"
   set the mainStack of stack "HyperTalkSub" to sStack
   set the script of card 1 of stack "HyperTalkSub" to "on doMenu pItem" & return & "end doMenu"
   TestAssert "a substack follows its mainstack", the result is empty
   _DeleteStack
end TestHyperTalkCompatibleSubstack

on TestHyperTalkCompatibleSaved
   local tPath
   _MakeStack true
   put specialFolderPath("temporary") & slash & sStack & ".livecode" into tPath
   save stack sStack as tPath
   delete stack sStack
   TestAssert "the stack is gone before it is opened again", there is not a stack sStack
   TestAssert "a saved stack opens with its hyperTalkCompatible", \
         the hyperTalkCompatible of stack tPath is true
   TestAssert "and HyperCard's message order", \
         _Order(the long id of button "B" of stack sStack) is the short name of card 1 of stack sStack & ",BG," & sStack & ","
   _DeleteStack
   delete file tPath
end TestHyperTalkCompatibleSaved
