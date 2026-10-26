script "CoreEngineHyperTalkCompatible"
/*
OXT-Beyond: the hyperTalkCompatible of a stack, which File > Import Stack
sets for a stack imported from HyperCard. Off, every message goes where
it always went; on, a background part's message reaches the card before
the background, a handler can be called doMenu, and doMenu is a message
before it runs, even while messages are locked, as in HyperCard;
lockRecent keeps no card of the stack out of the recent cards that go
back goes through; a handler that went to another stack still reaches
its own stack's script before the dynamic path, and one that went to
another card of its own stack reaches that card after it; arithmetic
that gives no number goes on with HyperCard's INF or NAN instead of
stopping the script; reading the textFont, textSize, textStyle or
textHeight of a button, a field or a field's text with none of its own
gives the one it uses, where it would give empty, HyperCard's own style
names (condense, outline...) set a textStyle, and grouped text reads as
group, not link, and is drawn as plain text, underlined only after show
groups; round takes a number halfway between two integers to the even
one; the seconds, and dates converted to and from seconds, count from
1904 in local time; numToChar and charToNum number the characters as
HyperCard did, by the Mac's character set with the return as 13; a
script can set the script of an object whose handler runs, which takes
it at once while that handler goes on; the id of a card is "card id" and
its number, which a script can go back to; the userLevel is at most 5,
HyperCard's highest; and play plays the sound a field or a button names
with card or background before it, as HyperCard did, of another card too
and in text run by do. Each test checks the stack with the property off
too.
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

-- The test's stack, whose script logs "hcMine" and "hcBoth" and passes
-- "hcBoth" on, and a second stack, whose script logs "hcTheirs" and
-- "hcBoth", both with the dynamicPaths of a stack imported from
-- HyperCard. Button "C" goes to the second stack and then sends the three
-- messages: what the scripts logged, "no" and the message for one that
-- found no handler, or empty if the button did not get to the second
-- stack
private function _AfterGoToOtherStack
   global gHCOrder
   local tOther, tLog, tScript, tMessage
   put sStack & "Other" into tOther
   set the dynamicPaths of stack sStack to true
   put "on hcLog pWhat" & return & "global gHCOrder" & return \
         & "put pWhat & comma after gHCOrder" & return & "end hcLog" into tLog
   set the script of stack sStack to "on hcMine" & return & "hcLog " & quote & "mine" & quote & return \
         & "end hcMine" & return & "on hcBoth" & return & "hcLog " & quote & "both here" & quote & return \
         & "pass hcBoth" & return & "end hcBoth" & return & tLog
   create invisible stack tOther
   set the dynamicPaths of stack tOther to true
   set the script of stack tOther to "on hcTheirs" & return & "hcLog " & quote & "theirs" & quote & return \
         & "end hcTheirs" & return & "on hcBoth" & return & "hcLog " & quote & "both there" & quote & return \
         & "end hcBoth" & return & tLog
   put "on mouseUp pOther" & return & "global gHCOrder" & return & "local tError" & return & "go to stack pOther" & return \
         & "if the short name of this stack is not pOther then exit mouseUp" & return into tScript
   repeat for each item tMessage in "hcMine,hcTheirs,hcBoth"
      put "try" & return & tMessage & return & "catch tError" & return \
            & "put " & quote & "no" && tMessage & comma & quote & " after gHCOrder" & return \
            & "end try" & return after tScript
   end repeat
   put "end mouseUp" after tScript
   set the script of button "C" of stack sStack to tScript
   put empty into gHCOrder
   send "mouseUp" && quote & tOther & quote to button "C" of stack sStack
   if there is a stack tOther then delete stack tOther
   return gHCOrder
end _AfterGoToOtherStack

on TestHyperTalkCompatibleDynamicPathOff
   local tOrder
   _MakeStack false
   put _AfterGoToOtherStack() into tOrder
   if tOrder is empty then
      TestSkip "off: the dynamic path after a go to another stack", "the go to the other stack did not get there"
   else
      TestAssert "off: after a go to another stack, a message takes the other stack's path instead of its own stack's", \
            tOrder is "no hcMine,theirs,both there,"
   end if
   _DeleteStack
end TestHyperTalkCompatibleDynamicPathOff

-- HyperCard sent a message through the static path first (the object,
-- its card, background and stack), and then through the dynamic path
-- (the card a handler went to, its background and stack) to Home
on TestHyperTalkCompatibleDynamicPath
   local tOrder
   _MakeStack true
   put _AfterGoToOtherStack() into tOrder
   if tOrder is empty then
      TestSkip "on: the dynamic path after a go to another stack", "the go to the other stack did not get there"
   else
      TestAssert "on: after a go to another stack, a message reaches its own stack's script, then the other stack's", \
            tOrder is "mine,theirs,both here,both there,"
   end if
   _DeleteStack
end TestHyperTalkCompatibleDynamicPath

-- The test's stack with a second card named "two": the background "BG" on
-- both cards, a background "BG2" on card "two" alone, and a script on
-- each of them that logs what it is and passes "hcBoth" on. Button "C" on
-- card 1 goes to card "two" and then sends "hcCard", which only card
-- "two"'s script has, "hcBoth", which every script has, and "hcKick",
-- which the stack's script has and which calls "hcCard" from the stack:
-- what the scripts logged, "no" and the message for one that found no
-- handler, or empty if the button did not get to card "two"
private function _AfterGoToCard
   global gHCOrder
   local tLog, tScript, tMessage
   set the defaultStack to sStack
   set the dynamicPaths of stack sStack to true
   create card
   set the name of card 2 of stack sStack to "two"
   go card "two" of stack sStack
   -- (the backgroundBehavior puts "BG" on a new card by itself)
   if there is not a group "BG" of card "two" of stack sStack then \
         place group "BG" onto card "two" of stack sStack
   create group "BG2"
   set the backgroundBehavior of group "BG2" of card "two" of stack sStack to true
   put "on hcLog pWhat" & return & "global gHCOrder" & return \
         & "put pWhat & comma after gHCOrder" & return & "end hcLog" into tLog
   set the script of stack sStack to "on hcBoth" & return & "hcLog " & quote & "stack" & quote & return \
         & "pass hcBoth" & return & "end hcBoth" & return & "on hcKick" & return \
         & "hcLog " & quote & "kick" & quote & return & "hcCard" & return & "end hcKick" & return & tLog
   set the script of card 1 of stack sStack to "on hcBoth" & return \
         & "hcLog " & quote & "card1" & quote & return & "pass hcBoth" & return & "end hcBoth"
   set the script of group "BG" of stack sStack to "on hcBoth" & return \
         & "hcLog " & quote & "bg" & quote & return & "pass hcBoth" & return & "end hcBoth"
   set the script of group "BG2" of card "two" of stack sStack to "on hcBoth" & return \
         & "hcLog " & quote & "bg2" & quote & return & "pass hcBoth" & return & "end hcBoth"
   set the script of card "two" of stack sStack to "on hcCard" & return \
         & "hcLog " & quote & "card2" & quote & return & "end hcCard" & return & "on hcBoth" & return \
         & "hcLog " & quote & "card2" & quote & return & "pass hcBoth" & return & "end hcBoth"
   go card 1 of stack sStack
   put "on mouseUp" & return & "global gHCOrder" & return & "local tError" & return & "go card 2" & return \
         & "if the short name of this card is not " & quote & "two" & quote & " then exit mouseUp" & return into tScript
   repeat for each item tMessage in "hcCard,hcBoth,hcKick"
      put "try" & return & tMessage & return & "catch tError" & return \
            & "put " & quote & "no" && tMessage & comma & quote & " after gHCOrder" & return \
            & "end try" & return after tScript
   end repeat
   put "end mouseUp" after tScript
   set the script of button "C" of card 1 of stack sStack to tScript
   put empty into gHCOrder
   send "mouseUp" to button "C" of card 1 of stack sStack
   return gHCOrder
end _AfterGoToCard

on TestHyperTalkCompatibleDynamicCardOff
   local tOrder
   _MakeStack false
   put _AfterGoToCard() into tOrder
   if tOrder is empty then
      TestSkip "off: the dynamic path after a go to another card", "the go to the other card did not get there"
   else if the environment begins with "development" then
      -- the home stack sends the message on to the card gone to, which
      -- sends it through that card's backgrounds and the stack a second time
      TestAssert "off: after a go to another card, a message still takes the static path first", \
            tOrder contains "card1,bg,stack,"
   else
      TestAssert "off: with no home stack, after a go to another card a message never reaches the card gone to", \
            tOrder is "no hcCard,card1,bg,stack,no hcBoth,kick,no hcKick,"
   end if
   _DeleteStack
end TestHyperTalkCompatibleDynamicCardOff

-- HyperCard's dynamic path also took in a card of the handler's own stack
-- that it had gone to: a message that reached the stack unhandled went on
-- to the card gone to and the backgrounds of that card it had not been
-- through, and then to Home, no object getting it twice
on TestHyperTalkCompatibleDynamicCard
   local tOrder
   _MakeStack true
   put _AfterGoToCard() into tOrder
   if tOrder is empty then
      TestSkip "on: the dynamic path after a go to another card", "the go to the other card did not get there"
   else
      TestAssert "the background is on both cards", there is a group "BG" of card "two" of stack sStack
      TestAssert "on: after a go to another card, a message reaches that card and its own backgrounds after the stack, once each", \
            tOrder is "card2,card1,bg,stack,card2,bg2,no hcBoth,kick,card2,"
   end if
   _DeleteStack
end TestHyperTalkCompatibleDynamicCard

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

-- Each line of pStatements run by a script of the stack (button "C"'s),
-- with tValue 7 before it: tValue after it, one a line, or "error" where
-- the statement stopped the script
private function _Values pStatements
   global gHCValues, gHCStatements
   set the script of button "C" of stack sStack to "on hcValues" & return \
         & "global gHCValues, gHCStatements" & return & "local tStatement, tValue, tError" & return \
         & "put empty into gHCValues" & return \
         & "repeat for each line tStatement in gHCStatements" & return \
         & "put 7 into tValue" & return & "try" & return & "do tStatement" & return \
         & "put tValue & return after gHCValues" & return \
         & "catch tError" & return & "put " & quote & "error" & quote & " & return after gHCValues" & return \
         & "end try" & return & "end repeat" & return & "end hcValues"
   put pStatements into gHCStatements
   put empty into gHCValues
   send "hcValues" to button "C" of stack sStack
   return gHCValues
end _Values

-- pValue between brackets: compared so, an INF or a NAN is compared as
-- text, where as a number a NAN is equal to nothing and "inf" is "INF"
private function _Shown pValue
   return "[" & pValue & "]"
end _Shown

on TestHyperTalkCompatibleArithmeticOff
   local tValues
   _MakeStack false
   put _Values("put 1/0 into tValue" & return & "put 0/0 into tValue" & return \
         & "divide tValue by 0" & return & "put sqrt(-1) into tValue" & return \
         & "put ln(0) into tValue" & return & "put 10^400 into tValue" & return \
         & "put 7 div 0 into tValue" & return & "put 1/4 into tValue" & return \
         & "put (" & quote & "nan" & quote & " + 0) is " & quote & "nan" & quote & " into tValue") into tValues
   TestAssert "off: 1/0 stops the script", line 1 of tValues is "error"
   TestAssert "off: 0/0 stops the script", line 2 of tValues is "error"
   TestAssert "off: divide by 0 stops the script", line 3 of tValues is "error"
   TestAssert "off: sqrt(-1) stops the script", line 4 of tValues is "error"
   TestAssert "off: ln(0) stops the script", line 5 of tValues is "error"
   TestAssert "off: 10^400 stops the script", line 6 of tValues is "error"
   TestAssert "off: div by 0 stops the script", line 7 of tValues is "error"
   TestAssert "off: 1/4 is 0.25", line 8 of tValues is "0.25"
   TestAssert "off: a NAN is equal to nothing, its own text included", line 9 of tValues is "false"
   _DeleteStack
end TestHyperTalkCompatibleArithmeticOff

-- HyperCard's numbers (SANE's) had infinities and NANs, and it showed a
-- NAN with the code of what made it: 1/0 was INF, sqrt(-1) -NAN(001) and
-- ln(-1) NAN(036) there. div and mod by zero stopped the script, as here
on TestHyperTalkCompatibleArithmetic
   local tValues
   _MakeStack true
   put _Values("put 1/0 into tValue" & return & "put -1/0 into tValue" & return \
         & "put 0/0 into tValue" & return & "divide tValue by 0" & return \
         & "put 1/0 + 1 into tValue" & return & "put 1/0 > 10^300 into tValue" & return \
         & "put 1/0 is " & quote & "INF" & quote & " into tValue" & return \
         & "put (0/0) * 100 into tValue" & return & "put sqrt(-1) into tValue" & return \
         & "put ln(-1) into tValue" & return & "put ln(0) into tValue" & return \
         & "put asin(2) into tValue" & return & "put (-8)^(1/3) into tValue" & return \
         & "put 10^400 into tValue" & return & "put 7 div 0 into tValue" & return \
         & "put 5 mod 0 into tValue" & return & "put 1/4 into tValue" & return \
         & "put (-8)^(1/3) is " & quote & "NAN(037)" & quote & " into tValue" & return \
         & "put " & quote & "NAN(036)" & quote & " + 0 into tValue" & return \
         & "put (" & quote & "nan" & quote & " + 0) is " & quote & "nan" & quote & " into tValue") into tValues
   set the caseSensitive to true
   TestAssert "on: 1/0 is INF", _Shown(line 1 of tValues) is "[INF]"
   TestAssert "on: -1/0 is -INF", _Shown(line 2 of tValues) is "[-INF]"
   TestAssert "on: 0/0 is NAN(004)", _Shown(line 3 of tValues) is "[NAN(004)]"
   TestAssert "on: 7 divided by 0 is INF", _Shown(line 4 of tValues) is "[INF]"
   TestAssert "on: INF + 1 is INF", _Shown(line 5 of tValues) is "[INF]"
   TestAssert "on: INF is more than any number", line 6 of tValues is "true"
   TestAssert "on: 1/0 is " & quote & "INF" & quote, line 7 of tValues is "true"
   TestAssert "on: a NAN times 100 is a NAN", char 1 to 4 of _Shown(line 8 of tValues) is "[NAN"
   TestAssert "on: sqrt(-1) is -NAN(001)", _Shown(line 9 of tValues) is "[-NAN(001)]"
   TestAssert "on: ln(-1) is NAN(036)", _Shown(line 10 of tValues) is "[NAN(036)]"
   TestAssert "on: ln(0) is -INF", _Shown(line 11 of tValues) is "[-INF]"
   TestAssert "on: asin(2) is NAN(034)", _Shown(line 12 of tValues) is "[NAN(034)]"
   TestAssert "on: (-8)^(1/3) is NAN(037)", _Shown(line 13 of tValues) is "[NAN(037)]"
   TestAssert "on: 10^400 is INF", _Shown(line 14 of tValues) is "[INF]"
   TestAssert "on: div by 0 still stops the script", line 15 of tValues is "error"
   TestAssert "on: mod by 0 still stops the script", line 16 of tValues is "error"
   TestAssert "on: 1/4 is still 0.25", line 17 of tValues is "0.25"
   TestAssert "on: a NAN is compared as text, so (-8)^(1/3) is " & quote & "NAN(037)" & quote, \
         line 18 of tValues is "true"
   TestAssert "on: NAN(036) read from text keeps its code, in decimal", _Shown(line 19 of tValues) is "[NAN(036)]"
   TestAssert "on: a NAN read from text is equal to its text", line 20 of tValues is "true"

   -- a field shows them as HyperCard did
   set the defaultStack to sStack
   create field "F"
   set the script of button "C" of stack sStack to "on mouseUp" & return & "local tError" & return \
         & "try" & return & "put 1/0 & comma & 0/0 into field " & quote & "F" & quote & return \
         & "catch tError" & return & "put " & quote & "error" & quote & " into field " & quote & "F" & quote & return \
         & "end try" & return & "end mouseUp"
   send "mouseUp" to button "C" of stack sStack
   TestAssert "on: a field shows 1/0 and 0/0 as INF and NAN(004)", field "F" of stack sStack is "INF,NAN(004)"
   _DeleteStack
end TestHyperTalkCompatibleArithmetic

-- round(2.5), round(3.5), round(-2.5), round(0.5), the round of (5.5 + 3)
-- and the round of 5.5 + 3 (the HyperTalk Reference's two examples),
-- round(2.6), round with a precision, and statRound(2.5)
private function _RoundValues
   return _Values("put round(2.5) into tValue" & return & "put round(3.5) into tValue" & return \
         & "put round(-2.5) into tValue" & return & "put round(0.5) into tValue" & return \
         & "put the round of (5.5 + 3) into tValue" & return & "put the round of 5.5 + 3 into tValue" & return \
         & "put round(2.6) into tValue" & return & "put round(2.5, 0) into tValue" & return \
         & "put round(0.125, 2) into tValue" & return & "put statRound(2.5) into tValue")
end _RoundValues

on TestHyperTalkCompatibleRoundOff
   local tValues
   _MakeStack false
   put _RoundValues() into tValues
   TestAssert "off: round(2.5) is 3", line 1 of tValues is "3"
   TestAssert "off: round(3.5) is 4", line 2 of tValues is "4"
   TestAssert "off: round(-2.5) is -3", line 3 of tValues is "-3"
   TestAssert "off: round(0.5) is 1", line 4 of tValues is "1"
   TestAssert "off: the round of (5.5 + 3) is 9", line 5 of tValues is "9"
   TestAssert "off: the round of 5.5 + 3 is 9", line 6 of tValues is "9"
   TestAssert "off: round(2.6) is 3", line 7 of tValues is "3"
   TestAssert "off: round(2.5, 0) is 3", line 8 of tValues is "3"
   TestAssert "off: round(0.125, 2) is 0.13", line 9 of tValues is "0.13"
   TestAssert "off: statRound(2.5) is 2", line 10 of tValues is "2"
   _DeleteStack
end TestHyperTalkCompatibleRoundOff

-- HyperCard's round took a number halfway between two integers to the
-- even one: "odd integers plus exactly 0.5 round up; even integers (or 0)
-- plus exactly 0.5 round down", a negative number as its absolute value
-- (the HyperTalk Reference, whose examples are "the round of 5.5 + 3 --
-- returns 9" and "the round of (5.5 + 3) -- returns 8"). round with a
-- precision, which HyperCard did not have, is the same in every stack
on TestHyperTalkCompatibleRound
   local tValues
   _MakeStack true
   put _RoundValues() into tValues
   TestAssert "on: round(2.5) is 2", line 1 of tValues is "2"
   TestAssert "on: round(3.5) is 4", line 2 of tValues is "4"
   TestAssert "on: round(-2.5) is -2", line 3 of tValues is "-2"
   TestAssert "on: round(0.5) is 0", line 4 of tValues is "0"
   TestAssert "on: the round of (5.5 + 3) is 8", line 5 of tValues is "8"
   TestAssert "on: the round of 5.5 + 3 is 9", line 6 of tValues is "9"
   TestAssert "on: round(2.6) is 3", line 7 of tValues is "3"
   TestAssert "on: round(2.5, 0) is still 3", line 8 of tValues is "3"
   TestAssert "on: round(0.125, 2) is still 0.13", line 9 of tValues is "0.13"
   TestAssert "on: statRound(2.5) is 2", line 10 of tValues is "2"
   _DeleteStack
end TestHyperTalkCompatibleRound

-- On the test's stack, which has the textFont Geneva and the textSize 12:
-- a button "Plain" with no font, size or style of its own (as the import
-- leaves many buttons), a button "Bold" with a style of its own and no
-- size, a button "Sized" whose textSize a script set, which sets its
-- textHeight to none, and a field "F", italic and 14 point, whose first
-- word is in Courier and second word bold. Each line of _TextStatements
-- reads one of their text properties
private command _MakeTextObjects
   set the defaultStack to sStack
   set the textFont of stack sStack to "Geneva"
   set the textSize of stack sStack to 12
   create button "Plain"
   create button "Bold"
   set the textStyle of button "Bold" to "bold"
   create button "Sized"
   set the textSize of button "Sized" to 10
   create field "F"
   set the textStyle of field "F" to "italic"
   set the textSize of field "F" to 14
   put "one two" & return & "three" into field "F"
   set the textFont of word 1 of field "F" to "Courier"
   set the textStyle of word 2 of field "F" to "bold"
end _MakeTextObjects

private function _TextStatements
   local q
   put quote into q
   return "put the textFont of button " & q & "Plain" & q & " into tValue" & return \
         & "put the textSize of button " & q & "Plain" & q & " into tValue" & return \
         & "put the textStyle of button " & q & "Plain" & q & " into tValue" & return \
         & "put the textHeight of button " & q & "Plain" & q & " into tValue" & return \
         & "put the textStyle of button " & q & "Bold" & q & " into tValue" & return \
         & "put the effective textStyle of button " & q & "Bold" & q & " into tValue" & return \
         & "put the textHeight of button " & q & "Sized" & q & " into tValue" & return \
         & "put the textFont of word 1 of field " & q & "F" & q & " into tValue" & return \
         & "put the textFont of word 2 of field " & q & "F" & q & " into tValue" & return \
         & "put the textSize of word 2 of field " & q & "F" & q & " into tValue" & return \
         & "put the textStyle of line 2 of field " & q & "F" & q & " into tValue" & return \
         & "put the textStyle of word 2 of field " & q & "F" & q & " into tValue" & return \
         & "put the textStyle of line 1 of field " & q & "F" & q & " into tValue" & return \
         & "put the textFont of line 1 of field " & q & "F" & q & " into tValue"
end _TextStatements

on TestHyperTalkCompatibleTextPropertiesOff
   local tValues
   _MakeStack false
   _MakeTextObjects
   put _Values(_TextStatements()) into tValues
   TestAssert "off: a button with no font of its own has an empty textFont", line 1 of tValues is empty
   TestAssert "off: and an empty textSize", line 2 of tValues is empty
   TestAssert "off: and an empty textStyle", line 3 of tValues is empty
   TestAssert "off: and an empty textHeight", line 4 of tValues is empty
   TestAssert "off: a button's own style", line 5 of tValues is "bold"
   TestAssert "off: the effective textStyle of a button with a style but no size of its own is still its owner's", \
         line 6 of tValues is "plain"
   TestAssert "off: setting the textSize leaves the textHeight empty", line 7 of tValues is empty
   TestAssert "off: text with a font of its own", line 8 of tValues is "Courier"
   TestAssert "off: text with no font of its own has an empty textFont", line 9 of tValues is empty
   TestAssert "off: and an empty textSize", line 10 of tValues is empty
   TestAssert "off: text with no style of its own has an empty textStyle", line 11 of tValues is empty
   TestAssert "off: text with a style of its own", line 12 of tValues is "bold"
   TestAssert "off: a line with a style in part of it is mixed", line 13 of tValues is "mixed"
   TestAssert "off: a line with a font in part of it is mixed", line 14 of tValues is "mixed"
   _DeleteStack
end TestHyperTalkCompatibleTextPropertiesOff

-- In HyperCard every button and field had its own font, size, style and
-- height, and the text of a field had the field's unless a style run gave
-- it others, so reading one always gave the one in use
on TestHyperTalkCompatibleTextProperties
   local tValues
   _MakeStack true
   _MakeTextObjects
   put _Values(_TextStatements()) into tValues
   TestAssert "on: a button with no font of its own gives the stack's", line 1 of tValues is "Geneva"
   TestAssert "on: and the stack's size", line 2 of tValues is 12
   TestAssert "on: and plain", line 3 of tValues is "plain"
   TestAssert "on: and the height of its size", line 4 of tValues is 16
   TestAssert "on: a button's own style", line 5 of tValues is "bold"
   TestAssert "on: the effective textStyle of a button with a style but no size of its own is its own", \
         line 6 of tValues is "bold"
   TestAssert "on: setting the textSize to 10 gives the height of that size", line 7 of tValues is 13
   TestAssert "on: text with a font of its own", line 8 of tValues is "Courier"
   TestAssert "on: text with no font of its own gives the field's, which is the stack's", line 9 of tValues is "Geneva"
   TestAssert "on: and the field's size", line 10 of tValues is 14
   TestAssert "on: text with no style of its own gives the field's", line 11 of tValues is "italic"
   TestAssert "on: text with a style of its own", line 12 of tValues is "bold"
   TestAssert "on: a line in two styles is mixed", line 13 of tValues is "mixed"
   TestAssert "on: a line in two fonts is mixed", line 14 of tValues is "mixed"
   _DeleteStack
end TestHyperTalkCompatibleTextProperties

-- HyperCard's own style names in a value, where the import's rule T32
-- cannot rewrite them: "bold,outline" on the button "Plain",
-- "condense" on the button "Bold", "extend,shadow" on the first word of
-- the field "F", "shadow" on the button "Sized", and "bold ,italic,",
-- with a space and an empty style, on the button "Plain", each set and
-- read
private function _StyleNameStatements
   local q
   put quote into q
   return "set the textStyle of button " & q & "Plain" & q & " to (" & q & "bold," & q & " & " & q & "outline" & q & ")" & return \
         & "put the textStyle of button " & q & "Plain" & q & " into tValue" & return \
         & "set the textStyle of button " & q & "Bold" & q & " to (" & q & "condense" & q & ")" & return \
         & "put the textStyle of button " & q & "Bold" & q & " into tValue" & return \
         & "set the textStyle of word 1 of field " & q & "F" & q & " to (" & q & "extend," & q & " & " & q & "shadow" & q & ")" & return \
         & "put the textStyle of word 1 of field " & q & "F" & q & " into tValue" & return \
         & "set the textStyle of button " & q & "Sized" & q & " to (" & q & "shadow" & q & ")" & return \
         & "put the textStyle of button " & q & "Sized" & q & " into tValue" & return \
         & "set the textStyle of button " & q & "Plain" & q & " to (" & q & "bold ,italic," & q & ")" & return \
         & "put the textStyle of button " & q & "Plain" & q & " into tValue"
end _StyleNameStatements

on TestHyperTalkCompatibleTextStyleNamesOff
   local tValues
   _MakeStack false
   _MakeTextObjects
   put _Values(_StyleNameStatements()) into tValues
   TestAssert "off: setting the textStyle to bold,outline stops the script", line 1 of tValues is "error"
   TestAssert "off: and leaves the style as it was", line 2 of tValues is empty
   TestAssert "off: condense stops the script", line 3 of tValues is "error"
   TestAssert "off: and leaves the style as it was", line 4 of tValues is "bold"
   TestAssert "off: extend,shadow on text stops the script", line 5 of tValues is "error"
   TestAssert "off: and leaves its style as it was", line 6 of tValues is empty
   TestAssert "off: shadow stops the script", line 7 of tValues is "error"
   TestAssert "off: and leaves the style as it was", line 8 of tValues is empty
   TestAssert "off: a space after a style, or an empty style, stops the script", line 9 of tValues is "error"
   TestAssert "off: and leaves the style as it was", line 10 of tValues is empty
   _DeleteStack
end TestHyperTalkCompatibleTextStyleNamesOff

-- HyperCard's condense and extend are condensed and expanded here, and its
-- outline and shadow, which this engine does not draw, are left out, with
-- the spaces after a style and an empty style, as the HyperCard Library's
-- hcTextStyle leaves them out of a style written in a script
on TestHyperTalkCompatibleTextStyleNames
   local tValues
   _MakeStack true
   _MakeTextObjects
   put _Values(_StyleNameStatements()) into tValues
   TestAssert "on: bold,outline is set", line 1 of tValues is 7
   TestAssert "on: as bold", line 2 of tValues is "bold"
   TestAssert "on: condense is set", line 3 of tValues is 7
   TestAssert "on: as condensed", line 4 of tValues is "condensed"
   TestAssert "on: extend,shadow on text is set", line 5 of tValues is 7
   TestAssert "on: as expanded", line 6 of tValues is "expanded"
   TestAssert "on: shadow is set", line 7 of tValues is 7
   TestAssert "on: as plain", line 8 of tValues is "plain"
   TestAssert "on: a space after a style, and an empty style, are left out", line 9 of tValues is 7
   TestAssert "on: so bold ,italic, is bold and italic", line 10 of tValues is "bold,italic"
   _DeleteStack
end TestHyperTalkCompatibleTextStyleNames

-- Grouped text, HyperCard's group style, which this engine calls link:
-- the second word of the field "F" set to group and the second line to
-- bold,link, each read, and whether "group" is in the style of the word,
-- as a HyperCard script tests a clicked link
private function _GroupStatements
   local q
   put quote into q
   return "set the textStyle of word 2 of field " & q & "F" & q & " to " & q & "group" & q & return \
         & "put the textStyle of word 2 of field " & q & "F" & q & " into tValue" & return \
         & "put " & q & "group" & q & " is in the textStyle of word 2 of field " & q & "F" & q & " into tValue" & return \
         & "set the textStyle of line 2 of field " & q & "F" & q & " to " & q & "bold,link" & q & return \
         & "put the textStyle of line 2 of field " & q & "F" & q & " into tValue" & return \
         & "put the effective textStyle of word 2 of field " & q & "F" & q & " into tValue"
end _GroupStatements

on TestHyperTalkCompatibleGroupStyleOff
   local tValues
   _MakeStack false
   _MakeTextObjects
   put _Values(_GroupStatements()) into tValues
   TestAssert "off: group is set", line 1 of tValues is 7
   TestAssert "off: as link", line 2 of tValues is "link"
   TestAssert "off: so group is not in its style", line 3 of tValues is false
   TestAssert "off: bold,link is set", line 4 of tValues is 7
   TestAssert "off: as bold,link", line 5 of tValues is "bold,link"
   TestAssert "off: the effective textStyle is link", line 6 of tValues is "link"
   _DeleteStack
end TestHyperTalkCompatibleGroupStyleOff

-- HyperCard's grouped text reads as group, by HyperCard's name, so that
-- if the textStyle of the clickChunk contains "group" finds a link
on TestHyperTalkCompatibleGroupStyle
   local tValues
   _MakeStack true
   _MakeTextObjects
   put _Values(_GroupStatements()) into tValues
   TestAssert "on: group is set", line 1 of tValues is 7
   TestAssert "on: as group", line 2 of tValues is "group"
   TestAssert "on: so group is in its style", line 3 of tValues is true
   TestAssert "on: bold,link is set", line 4 of tValues is 7
   TestAssert "on: as bold,group", line 5 of tValues is "bold,group"
   TestAssert "on: the effective textStyle is group", line 6 of tValues is "group"
   _DeleteStack
end TestHyperTalkCompatibleGroupStyle

-- A locked field "L" on the test's stack whose second word has the style
-- pStyle, as it is drawn: how many pixels of its snapshot are blue, as
-- link text is drawn here, and how many are dark, as text in the field's
-- own colour is, as "blue,dark"
private function _Look pStyle
   local tData, tBlue, tDark, r, g, b, i
   set the defaultStack to sStack
   if there is not a field "L" then
      create field "L"
      set the rect of field "L" to 0,0,200,40
      set the lockText of field "L" to true
      put "one two three" into field "L"
   end if
   set the textStyle of word 2 of field "L" to pStyle
   import snapshot from field "L"
   put the imageData of last image into tData
   delete last image
   put 0 into tBlue
   put 0 into tDark
   repeat with i = 0 to (the number of bytes of tData) div 4 - 1
      put byteToNum(byte i * 4 + 2 of tData) into r
      put byteToNum(byte i * 4 + 3 of tData) into g
      put byteToNum(byte i * 4 + 4 of tData) into b
      if b > r + 60 and b > g + 60 then add 1 to tBlue
      if r < 100 and g < 100 and b < 100 then add 1 to tDark
   end repeat
   return tBlue & comma & tDark
end _Look

-- Link text is drawn in the link colour, and hide groups takes its
-- underline off (the global underlineLinks, given back after)
on TestHyperTalkCompatibleGroupLookOff
   local tUnderlineLinks, tPlain, tShown, tHidden
   put the underlineLinks into tUnderlineLinks
   _MakeStack false
   put _Look("plain") into tPlain
   show groups
   put _Look("link") into tShown
   hide groups
   put _Look("link") into tHidden
   set the underlineLinks to tUnderlineLinks
   TestAssert "off: link text is drawn in the link colour", item 1 of tShown > item 1 of tPlain
   TestAssert "off: and after hide groups", item 1 of tHidden > item 1 of tPlain
   TestAssert "off: hide groups takes the underline off", tHidden is not tShown
   _DeleteStack
end TestHyperTalkCompatibleGroupLookOff

-- HyperCard drew grouped text as the text it was, in its own colour, and
-- underlined it only after show groups, which it started without; a
-- stack with a link colour of its own draws its link text in it
on TestHyperTalkCompatibleGroupLook
   local tUnderlineLinks, tPlain, tUnderlined, tGroup, tShown, tHidden, tColoured, tColourless
   put the underlineLinks into tUnderlineLinks
   _MakeStack true
   put _Look("plain") into tPlain
   put _Look("underline") into tUnderlined
   put _Look("group") into tGroup
   show groups
   put _Look("group") into tShown
   hide groups
   put _Look("group") into tHidden
   set the linkColor of stack sStack to "0,0,255"
   put _Look("group") into tColoured
   set the linkColor of stack sStack to empty
   put _Look("group") into tColourless
   set the underlineLinks to tUnderlineLinks
   TestAssert "on: grouped text is drawn as plain text", tGroup is tPlain
   TestAssert "on: show groups underlines it", tShown is tUnderlined
   TestAssert "on: hide groups takes the underline off", tHidden is tPlain
   TestAssert "on: in a stack with a linkColor of its own, it is drawn in that colour", item 1 of tColoured > item 1 of tPlain
   TestAssert "on: and with the stack's linkColor empty again, as plain text", tColourless is tPlain
   _DeleteStack
end TestHyperTalkCompatibleGroupLook

-- In a script of the test's stack: 0 and 2643134400 (eight in the evening
-- of 3 October 1987, which the Star Trek stack counts down to) converted
-- to dateItems, 2643148800 from seconds to dateItems, 10/4/1987, 1/1/1904
-- and 1987,10,4,0,0,0,1 to seconds, whether 2643148800 is a date, the
-- seconds less the long seconds, the seconds of 10/31/2026 with two days'
-- more (86400 each) as a date, across the end of daylight saving time in
-- the United States on 1 November, and the seconds of 10/31/2026 mod 86400
private function _SecondsValues
   return _Values("put 0 into tValue;convert tValue to dateItems" & return \
         & "put 2643134400 into tValue;convert tValue to dateItems" & return \
         & "put 2643148800 into tValue;convert tValue from seconds to dateItems" & return \
         & "put" && quote & "10/4/1987" & quote && "into tValue;convert tValue to seconds" & return \
         & "put" && quote & "1/1/1904" & quote && "into tValue;convert tValue to seconds" & return \
         & "put" && quote & "1987,10,4,0,0,0,1" & quote && "into tValue;convert tValue to seconds" & return \
         & "put 2643148800 is a date into tValue" & return \
         & "put the seconds - trunc(the long seconds) into tValue" & return \
         & "put" && quote & "10/31/2026" & quote && "into tValue;convert tValue to seconds;" \
         & "add 2 * 86400 to tValue;convert tValue to short date" & return \
         & "put" && quote & "10/31/2026" & quote && "into tValue;convert tValue to seconds;" \
         & "put tValue mod 86400 into tValue")
end _SecondsValues

-- The local time's distance from universal time now, in seconds east of
-- it, from the internet date
private function _LocalOffset
   local tZone, tOffset
   put last word of the internet date into tZone
   put char 2 to 3 of tZone * 3600 + char 4 to 5 of tZone * 60 into tOffset
   if char 1 of tZone is "-" then return 0 - tOffset
   return tOffset
end _LocalOffset

-- New York's time zone for the engine, where it can be set: the engine
-- takes it from $TZ on Linux, if the system has it. True if it was; the
-- caller gives $TZ back
private function _SetNewYork
   local tSummer, tWinter
   if the platform is not "Linux" then return false
   put "America/New_York" into $TZ
   put "7/1/2026 12:00 PM" into tSummer
   convert tSummer to internet date
   put "1/1/2026 12:00 PM" into tWinter
   convert tWinter to internet date
   return last word of tSummer is "-0400" and last word of tWinter is "-0500"
end _SetNewYork

-- The engine counts the seconds from 1970 in universal time, so in New
-- York a date's seconds are 4 or 5 hours' more than a multiple of 86400,
-- and two days' more seconds from 10/31/2026 are an hour short of 11/2
on TestHyperTalkCompatibleSecondsOff
   local tValues, tZone
   _MakeStack false
   put _SecondsValues() into tValues
   TestAssert "off: 0 seconds is in 1970, or on its eve west of Greenwich", \
         item 1 to 3 of line 1 of tValues is "1970,1,1" or item 1 to 3 of line 1 of tValues is "1969,12,31"
   TestAssert "off: 2643134400 seconds is not in 1987", item 1 of line 2 of tValues is not 1987
   TestAssert "off: nor 2643148800 from seconds", item 1 of line 3 of tValues is not 1987
   TestAssert "off: 10/4/1987 is 560304000 seconds, or the local time's distance from it", \
         abs(line 4 of tValues - 560304000) <= 50400
   TestAssert "off: 1/1/1904 is -2082844800 seconds, or the local time's distance from it", \
         abs(line 5 of tValues + 2082844800) <= 50400
   TestAssert "off: 1987,10,4,0,0,0,1 is the seconds of 10/4/1987", line 6 of tValues is line 4 of tValues
   TestAssert "off: the seconds are the long seconds'", abs(line 8 of tValues) <= 1
   put $TZ into tZone
   if _SetNewYork() then
      put _SecondsValues() into tValues
      TestAssert "off, in New York: 10/4/1987 is 560318400 seconds", line 4 of tValues is 560318400
      TestAssert "off, in New York: two days' more seconds from 10/31/2026 are 11/1/26", line 9 of tValues is "11/1/26"
      TestAssert "off, in New York: the seconds of 10/31/2026 mod 86400 are 14400", line 10 of tValues is 14400
   else
      TestSkip "off, in New York's time zone", "the engine takes a time zone from $TZ only on Linux"
   end if
   put tZone into $TZ
   _DeleteStack
end TestHyperTalkCompatibleSecondsOff

private command _CheckHyperTalkSeconds pValues, pWhere
   TestAssert pWhere & ": 0 seconds is midnight on 1 January 1904, a Friday", line 1 of pValues is "1904,1,1,0,0,0,6"
   TestAssert pWhere & ": 2643134400 seconds is 8 PM on 3 October 1987, a Saturday", line 2 of pValues is "1987,10,3,20,0,0,7"
   TestAssert pWhere & ": 2643148800 from seconds is midnight on 4 October 1987", line 3 of pValues is "1987,10,4,0,0,0,1"
   TestAssert pWhere & ": 10/4/1987 is 2643148800 seconds", line 4 of pValues is 2643148800
   TestAssert pWhere & ": 1/1/1904 is 0 seconds", line 5 of pValues is 0
   TestAssert pWhere & ": 1987,10,4,0,0,0,1 is 2643148800 seconds", line 6 of pValues is 2643148800
   TestAssert pWhere & ": 2643148800 is a date", line 7 of pValues is true
   TestAssert pWhere & ": the seconds are the long seconds' from 1904, in local time", \
         abs(line 8 of pValues - 2082844800 - _LocalOffset()) <= 1
   TestAssert pWhere & ": two days' more seconds from 10/31/2026 are 11/2/26", line 9 of pValues is "11/2/26"
   TestAssert pWhere & ": the seconds of a date mod 86400 are 0", line 10 of pValues is 0
end _CheckHyperTalkSeconds

-- HyperCard counted its seconds from midnight on 1 January 1904 by the
-- Macintosh's clock, which kept local time, so a day was 86400 of them in
-- any time zone: a date's seconds with two days' more were the date two
-- days on, across a change of daylight saving time too, and the same
-- seconds were the same date and time wherever they were converted
on TestHyperTalkCompatibleSeconds
   local tValues, tZone
   _MakeStack true
   put _SecondsValues() into tValues
   _CheckHyperTalkSeconds tValues, "on"
   put $TZ into tZone
   if _SetNewYork() then
      put _SecondsValues() into tValues
      _CheckHyperTalkSeconds tValues, "on, in New York"
   else
      TestSkip "on, in New York's time zone", "the engine takes a time zone from $TZ only on Linux"
   end if
   put tZone into $TZ
   _DeleteStack
end TestHyperTalkCompatibleSeconds

-- numToChar of 165, 195 and 202 (a bullet, a check mark and a
-- non-breaking space in HyperCard) as code points; charToNum of a bullet,
-- a non-breaking space, an e with an acute accent and a Cyrillic letter
-- that neither set of characters has; charToNum(return); whether
-- numToChar(13) is the return; numToChar(10) as a code point; charToNum
-- of a carriage return; how many of the numbers 0 to 255 do not come back
-- from charToNum(numToChar(n)); the lines of text with numToChar(13) in
-- it, and of a script made so, as some stacks make their buttons'
-- scripts; charToNum of a byte; numToChar(65 + 256) and charToNum("A");
-- whether numToChar(165) and charToNum of a bullet are the platform's
-- (numToNativeChar and nativeCharToNum); and charToNum(numToChar(8226))
-- with the useUnicode true
private function _CharValues
   return _Values("put codepointToNum(numToChar(165)) into tValue" & return \
         & "put codepointToNum(numToChar(195)) into tValue" & return \
         & "put codepointToNum(numToChar(202)) into tValue" & return \
         & "put charToNum(numToCodepoint(8226)) into tValue" & return \
         & "put charToNum(numToCodepoint(160)) into tValue" & return \
         & "put charToNum(numToCodepoint(233)) into tValue" & return \
         & "put charToNum(numToCodepoint(1234)) into tValue" & return \
         & "put charToNum(return) into tValue" & return \
         & "put numToChar(13) is return into tValue" & return \
         & "put codepointToNum(numToChar(10)) into tValue" & return \
         & "put charToNum(numToCodepoint(13)) into tValue" & return \
         & "put 0 into tValue;repeat with tError = 0 to 255;" \
         & "if charToNum(numToChar(tError)) is not tError then add 1 to tValue;end repeat" & return \
         & "put the number of lines of (" & quote & "a" & quote & " & numToChar(13) & " & quote & "b" & quote & ") into tValue" & return \
         & "set the script of the owner of me to " & quote & "on hcCharsTest" & quote & " & numToChar(13) & " \
         & quote & "end hcCharsTest" & quote & ";put the number of lines of the script of the owner of me into tValue" & return \
         & "put charToNum(numToByte(165)) into tValue" & return \
         & "put numToChar(65 + 256) & charToNum(" & quote & "A" & quote & ") into tValue" & return \
         & "put codepointToNum(numToChar(165)) is codepointToNum(numToNativeChar(165)) into tValue" & return \
         & "put charToNum(numToCodepoint(8226)) is nativeCharToNum(numToCodepoint(8226)) into tValue" & return \
         & "set the useUnicode to true;put charToNum(numToChar(8226)) into tValue;set the useUnicode to false")
end _CharValues

-- The platform's characters: MacRoman on the Mac, Windows-1252 on
-- Windows, ISO 8859-1 on Linux, in which 10, a linefeed, is the return
on TestHyperTalkCompatibleCharsOff
   local tValues
   _MakeStack false
   put _CharValues() into tValues
   TestAssert "off: a Cyrillic letter is 63, a question mark", line 7 of tValues is 63
   TestAssert "off: charToNum(return) is 10", line 8 of tValues is 10
   TestAssert "off: numToChar(13) is not the return", line 9 of tValues is false
   TestAssert "off: numToChar(10) is code point 10, the return", line 10 of tValues is 10
   TestAssert "off: charToNum of a carriage return is 13", line 11 of tValues is 13
   TestAssert "off: charToNum(numToChar(n)) is n for 0 to 255", line 12 of tValues is 0
   TestAssert "off: numToChar(13) does not end a line", line 13 of tValues is 1
   TestAssert "off: nor a line of a script", line 14 of tValues is 1
   TestAssert "off: charToNum of byte 165 is 165", line 15 of tValues is 165
   TestAssert "off: numToChar(65 + 256) is A, and charToNum(A) 65", line 16 of tValues is "A65"
   TestAssert "off: numToChar(165) is the platform's character 165", line 17 of tValues is true
   TestAssert "off: charToNum of a bullet is the platform's number for it", line 18 of tValues is true
   TestAssert "off: with the useUnicode, charToNum(numToChar(8226)) is 8226", line 19 of tValues is 8226
   _DeleteStack
end TestHyperTalkCompatibleCharsOff

-- HyperCard's characters were the Mac's (MacRoman) on every Mac, and a
-- carriage return (13) ended a line of text or of a script, where a
-- linefeed (10) did not
on TestHyperTalkCompatibleChars
   local tValues
   _MakeStack true
   put _CharValues() into tValues
   TestAssert "on: numToChar(165) is a bullet, U+2022", line 1 of tValues is 8226
   TestAssert "on: numToChar(195) is a check mark, U+221A", line 2 of tValues is 8730
   TestAssert "on: numToChar(202) is a non-breaking space, U+00A0", line 3 of tValues is 160
   TestAssert "on: charToNum of a bullet is 165", line 4 of tValues is 165
   TestAssert "on: charToNum of a non-breaking space is 202", line 5 of tValues is 202
   TestAssert "on: charToNum of an e with an acute accent is 142", line 6 of tValues is 142
   TestAssert "on: a Cyrillic letter is still 63, a question mark", line 7 of tValues is 63
   TestAssert "on: charToNum(return) is 13", line 8 of tValues is 13
   TestAssert "on: numToChar(13) is the return", line 9 of tValues is true
   TestAssert "on: numToChar(10) is a carriage return, code point 13", line 10 of tValues is 13
   TestAssert "on: charToNum of a carriage return is 10", line 11 of tValues is 10
   TestAssert "on: charToNum(numToChar(n)) is n for 0 to 255", line 12 of tValues is 0
   TestAssert "on: numToChar(13) ends a line", line 13 of tValues is 2
   TestAssert "on: and a line of a script", line 14 of tValues is 2
   TestAssert "on: charToNum of byte 165 is still 165", line 15 of tValues is 165
   TestAssert "on: numToChar(65 + 256) is still A, and charToNum(A) 65", line 16 of tValues is "A65"
   TestAssert "on: with the useUnicode, charToNum(numToChar(8226)) is still 8226", line 19 of tValues is 8226
   _DeleteStack
end TestHyperTalkCompatibleChars

-- A button "T" whose hcToggle sets the script of the button itself, as a
-- button that changes its own script as it is clicked does, to one whose
-- hcToggle logs "new" and which has a handler the old one does not,
-- hcAdded, and goes on: it logs the last line of its button's script,
-- what hcWhich() gives and what hcAdded does. Then hcToggle once more,
-- and a button "Q" whose behavior's handler sets the behavior's script.
-- What they logged, one a line: "error" and its number where a set
-- stopped, "no hcAdded" where there was none
private function _SetScriptLog
   global gHCLog, gHCNewScript
   set the defaultStack to sStack
   create button "T"
   set the script of button "T" of stack sStack to "on hcToggle" & return \
         & "global gHCLog, gHCNewScript" & return & "local tError" & return \
         & "put " & quote & "old" & quote & " & return after gHCLog" & return \
         & "try" & return & "set the script of me to gHCNewScript" & return \
         & "put " & quote & "set" & quote & " & return after gHCLog" & return \
         & "catch tError" & return \
         & "put " & quote & "error " & quote & " & item 1 of line 1 of tError & return after gHCLog" & return \
         & "end try" & return \
         & "put last line of the script of me & return after gHCLog" & return \
         & "put hcWhich() & return after gHCLog" & return \
         & "try" & return & "hcAdded" & return & "catch tError" & return \
         & "put " & quote & "no hcAdded" & quote & " & return after gHCLog" & return \
         & "end try" & return & "end hcToggle" & return \
         & "function hcWhich" & return & "return " & quote & "old" & quote & return & "end hcWhich"
   put "on hcToggle" & return & "global gHCLog" & return \
         & "put " & quote & "new" & quote & " & return after gHCLog" & return & "end hcToggle" & return \
         & "function hcWhich" & return & "return " & quote & "new" & quote & return & "end hcWhich" & return \
         & "on hcAdded" & return & "global gHCLog" & return \
         & "put " & quote & "added" & quote & " & return after gHCLog" & return & "end hcAdded" into gHCNewScript
   create button "P"
   set the script of button "P" of stack sStack to "on hcBehave" & return \
         & "global gHCLog" & return & "local tError" & return \
         & "try" & return & "set the script of button " & quote & "P" & quote & " of stack " \
         & quote & sStack & quote & " to empty" & return \
         & "put " & quote & "set" & quote & " & return after gHCLog" & return \
         & "catch tError" & return \
         & "put " & quote & "error " & quote & " & item 1 of line 1 of tError & return after gHCLog" & return \
         & "end try" & return & "end hcBehave"
   create button "Q"
   set the behavior of button "Q" of stack sStack to the long id of button "P" of stack sStack
   put empty into gHCLog
   send "hcToggle" to button "T" of stack sStack
   send "hcToggle" to button "T" of stack sStack
   send "hcBehave" to button "Q" of stack sStack
   return gHCLog
end _SetScriptLog

on TestHyperTalkCompatibleSetScriptOff
   local tLog
   _MakeStack false
   put _SetScriptLog() into tLog
   TestAssert "off: setting the script of an object whose handler runs stops the script", \
         line 2 of tLog is "error 360"
   TestAssert "off: so the object keeps its script", line 3 of tLog is "end hcWhich"
   TestAssert "off: and its messages go to it", line 4 of tLog is "old" and line 5 of tLog is "no hcAdded"
   TestAssert "off: the next one too", line 6 of tLog is "old" and line 7 of tLog is "error 360"
   TestAssert "off: a behavior's script, while its handler runs, is not set either", \
         line 11 of tLog is "error 360"
   _DeleteStack
end TestHyperTalkCompatibleSetScriptOff

-- In HyperCard a script could set the script of an object whose handler
-- ran, and the handler went on: a button changed its own script as it was
-- clicked, so that the next click did something else
on TestHyperTalkCompatibleSetScript
   local tLog
   _MakeStack true
   put _SetScriptLog() into tLog
   TestAssert "on: a handler sets the script of its own object", line 2 of tLog is "set"
   TestAssert "on: which is the object's script at once", line 3 of tLog is "end hcAdded"
   TestAssert "on: and takes the messages the handler sends after it", \
         line 4 of tLog is "new" and line 5 of tLog is "added"
   TestAssert "on: and the next one", line 6 of tLog is "new" and the number of lines of tLog is 7
   TestAssert "on: a behavior's script, while its handler runs, is still not set", \
         line 7 of tLog is "error 360"
   _DeleteStack
end TestHyperTalkCompatibleSetScript

-- The id of the stack's card, its short id, the id of its background
-- group and of a button, whether the card's id is "card id" and its short
-- id, and its abbreviated id, one a line
private function _IdValues
   return _Values("put the id of card 1 into tValue" & return \
         & "put the short id of card 1 into tValue" & return \
         & "put the id of group " & quote & "BG" & quote & " into tValue" & return \
         & "put the id of button " & quote & "C" & quote & " into tValue" & return \
         & "put the id of card 1 is (" & quote & "card id" & quote & " && the short id of card 1) into tValue" & return \
         & "put the abbreviated id of card 1 into tValue")
end _IdValues

-- A handler that keeps the id of card 1, goes to card 2 and goes to what
-- it kept, as HyperCard stacks did: the number of the card it is on then
private function _GoBackToId
   global gHCLog
   set the defaultStack to sStack
   create card
   set the script of button "C" of card 1 of stack sStack to "on hcGoBack" & return \
         & "global gHCLog" & return & "local tCard, tError" & return \
         & "put the id of card 1 into tCard" & return \
         & "go to card 2" & return \
         & "try" & return & "go tCard" & return & "catch tError" & return & "end try" & return \
         & "put the number of this card into gHCLog" & return & "end hcGoBack"
   put empty into gHCLog
   send "hcGoBack" to button "C" of card 1 of stack sStack
   return gHCLog
end _GoBackToId

on TestHyperTalkCompatibleCardIdOff
   local tValues
   _MakeStack false
   put _IdValues() into tValues
   TestAssert "off: the id of a card is its number", line 1 of tValues is line 2 of tValues and line 2 of tValues is an integer
   TestAssert "off: the id of a background is its number", line 3 of tValues is an integer
   TestAssert "off: the id of a button is its number", line 4 of tValues is an integer
   TestAssert "off: so it is not card id and that number", line 5 of tValues is "false"
   TestAssert "off: the abbreviated id of a card is card id and its number", line 6 of tValues is "card id" && line 2 of tValues
   TestAssert "off: a handler that goes to a card's id goes nowhere", _GoBackToId() is 2
   _DeleteStack
end TestHyperTalkCompatibleCardIdOff

-- In HyperCard the id of a card was "card id 1234", and stacks kept it to
-- go back to it ("put the id of this card into tCard" ... "go tCard") or
-- compared it with one ("if the id of this card is "card id 3058""). The
-- id of a background, a button or a field was a number, as here
on TestHyperTalkCompatibleCardId
   local tValues
   _MakeStack true
   put _IdValues() into tValues
   TestAssert "on: the id of a card is card id and its number", line 1 of tValues is "card id" && line 2 of tValues
   TestAssert "on: the short id of a card is its number", line 2 of tValues is an integer
   TestAssert "on: the id of a background is its number", line 3 of tValues is an integer
   TestAssert "on: the id of a button is its number", line 4 of tValues is an integer
   TestAssert "on: so it is card id and that number", line 5 of tValues is "true"
   TestAssert "on: the abbreviated id of a card is card id and its number", line 6 of tValues is "card id" && line 2 of tValues
   TestAssert "on: a handler that goes to a card's id goes back to it", _GoBackToId() is 1
   _DeleteStack
end TestHyperTalkCompatibleCardId

-- The userLevel as the stack's script reads it, then after it sets it to
-- 3, and to 8, and whether it is 5 then, one a line
private function _UserLevelValues
   return _Values("put the userLevel into tValue" & return \
         & "set the userLevel to 3; put the userLevel into tValue" & return \
         & "set the userLevel to 8; put the userLevel into tValue" & return \
         & "put the userLevel is 5 into tValue")
end _UserLevelValues

on TestHyperTalkCompatibleUserLevelOff
   local tValues
   _MakeStack false
   put _UserLevelValues() into tValues
   TestAssert "off: the userLevel is 8", line 1 of tValues is 8
   TestAssert "off: as a script sets it", line 2 of tValues is 3 and line 3 of tValues is 8
   TestAssert "off: so it is not 5", line 4 of tValues is "false"
   _DeleteStack
end TestHyperTalkCompatibleUserLevelOff

-- HyperCard's userLevel went from 1 (browsing) to 5 (scripting), and its
-- stacks test for 5 ("if the userLevel is 5 then pass doMenu") or name a
-- button by it ("UserLevel" && the userLevel)
on TestHyperTalkCompatibleUserLevel
   local tValues
   _MakeStack true
   put _UserLevelValues() into tValues
   TestAssert "on: the userLevel is HyperCard's highest, 5", line 1 of tValues is 5
   TestAssert "on: one set below it is as it is set", line 2 of tValues is 3
   TestAssert "on: one set above it reads as 5", line 3 of tValues is 5 and line 4 of tValues is "true"
   TestAssert "on: and is kept as it was set, as a stack without the property reads it", the userLevel is 8
   _DeleteStack
end TestHyperTalkCompatibleUserLevel

-- A stack from HyperCard (HCAddressing) with a card field "Here" on card
-- 1 and a card field "Sound" on card 2, each naming a sound the stack
-- does not have, and a button "P" whose hcPlay plays card 2's from its
-- script, putting played or error into gHCPlayed
private command _MakePlayStack pCompatible
   local q
   put quote into q
   _MakeStack pCompatible
   set the HCAddressing of stack sStack to true
   create field "Here"
   put "HCPlayNoSuchSound" into card field "Here" of card 1 of stack sStack
   create button "P"
   set the script of button "P" of stack sStack to "on hcPlay" & return \
         & "global gHCPlayed" & return & "local tError" & return & "try" & return \
         & "play card field " & q & "Sound" & q & " of card 2" & return \
         & "put " & q & "played" & q & " into gHCPlayed" & return \
         & "catch tError" & return & "put " & q & "error" & q & " into gHCPlayed" & return \
         & "end try" & return & "play stop" & return & "end hcPlay"
   create card
   create field "Sound"
   put "HCPlayNoSuchSound" into card field "Sound" of card 2 of stack sStack
   go card 1 of stack sStack
end _MakePlayStack

-- play with a field of another card, the card's own field, a field the
-- background does not have, a sound by its name, another card's field
-- with a tempo and notes, and play stop, run by do, one a line: 7 where
-- it played, error where it stopped; then hcPlay's, from a script
private function _PlayValues
   global gHCPlayed
   local q, tValues
   put quote into q
   put _Values("play card field " & q & "Sound" & q & " of card 2" & return \
         & "play cd fld " & q & "Here" & q & return \
         & "play bg fld " & q & "Here" & q & return \
         & "play " & q & "HCPlayNoSuchSound" & q & return \
         & "play card field " & q & "Sound" & q & " of card 2 tempo 120 " & q & "c d e" & q & return \
         & "play stop") into tValues
   put empty into gHCPlayed
   send "hcPlay" to button "P" of stack sStack
   return tValues & gHCPlayed
end _PlayValues

on TestHyperTalkCompatiblePlayFieldOff
   local tValues
   _MakePlayStack false
   put _PlayValues() into tValues
   TestAssert "off: a field of another card is the background's, so no such object", line 1 of tValues is "error"
   TestAssert "off: and so is a field of the card", line 2 of tValues is "error"
   TestAssert "off: a field the background does not have is no such object", line 3 of tValues is "error"
   TestAssert "off: a sound by its name plays", line 4 of tValues is 7
   TestAssert "off: a field of another card with a tempo and notes is the background's", line 5 of tValues is "error"
   TestAssert "off: play stop", line 6 of tValues is 7
   TestAssert "off: in a script too", line 7 of tValues is "error"
   _DeleteStack
end TestHyperTalkCompatiblePlayFieldOff

-- HyperCard played the sound its first argument named, so "play card
-- field "x" of card "y"" played the one that card's field named (Christmas
-- Carols plays each carol with do fld "song", whose text is such a play)
on TestHyperTalkCompatiblePlayField
   local tValues
   _MakePlayStack true
   put _PlayValues() into tValues
   TestAssert "on: the sound a field of another card names plays", line 1 of tValues is 7
   TestAssert "on: and the one a field of the card names", line 2 of tValues is 7
   TestAssert "on: a field the background does not have is no such object", line 3 of tValues is "error"
   TestAssert "on: a sound by its name plays", line 4 of tValues is 7
   TestAssert "on: with a tempo and notes after the field", line 5 of tValues is 7
   TestAssert "on: play stop", line 6 of tValues is 7
   TestAssert "on: in a script too", line 7 of tValues is "played"
   _DeleteStack
end TestHyperTalkCompatiblePlayField
