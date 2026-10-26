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
gives the one it uses, where it would give empty, and HyperCard's own
style names (condense, outline...) set a textStyle; and round takes a
number halfway between two integers to the even one. Each test checks
the stack with the property off too.
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

-- HyperCard's own style names in a value, where the HyperCard Library's
-- rule T32 cannot rewrite them: "bold,outline" on the button "Plain",
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
