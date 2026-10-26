script "ArrayLiterals"
/*
Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond.

OXT-Beyond is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

OXT-Beyond is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with OXT-Beyond.  If not see <http://www.gnu.org/licenses/>.  */

-- Literal arrays, as in LiveCode 10 (openxtalk.org p=25426): a sequence,
-- [<value>, ...], whose keys are 1, 2, 3 and on, and an array of keys and
-- values, {<key>: <value>, ...}. "[" and "{" began no expression before,
-- so a handler that holds one did not compile, and is read with them (the
-- engine's MCNewSyntax): what compiled before compiles as it did, and
-- means what it did, as the tests at the end say. Text that is worked out
-- only if it compiles, a merge template's or a parameter of send given as
-- text, is read with none, and left as text as before.

on TestSequence
   local tList, tKeys
   put [10, "two", 1 + 2] into tList
   TestAssert "a sequence is an array", tList is an array
   put the keys of tList into tKeys
   sort lines of tKeys numeric
   TestAssert "its keys are 1 to 3", tKeys is "1" & return & "2" & return & "3"
   TestAssert "its first value", tList[1] is 10
   TestAssert "its second value", tList[2] is "two"
   TestAssert "a value worked out", tList[3] is 3
end TestSequence

on TestKeyed
   local tPerson
   put {"name": "Ada", "born": 1815, "languages": 2} into tPerson
   TestAssert "an array of keys and values", tPerson is an array
   TestAssert "three elements", the number of elements of tPerson is 3
   TestAssert "a value by its key", tPerson["name"] is "Ada"
   TestAssert "a number as a value", tPerson["born"] is 1815
end TestKeyed

on TestEmpty
   local tList, tKeyed
   put [] into tList
   put {} into tKeyed
   TestAssert "[] has no elements", the number of elements of tList is 0
   TestAssert "{} has no elements", the number of elements of tKeyed is 0
   TestAssert "[] is empty", tList is empty
   TestAssert "{} is empty", tKeyed is empty
   put "x" into tList[1]
   TestAssert "an element can be put into it", tList[1] is "x"
end TestEmpty

on TestTrailingComma
   local tList, tKeyed
   put [1, 2, 3,] into tList
   put {"a": 1, "b": 2,} into tKeyed
   TestAssert "a comma after a sequence's last value", the number of elements of tList is 3
   TestAssert "a comma after the last element", the number of elements of tKeyed is 2
end TestTrailingComma

on TestNested
   local tData
   put {"list": [1, [2, 3]], "map": {"x": {"y": "deep"}}, "none": []} into tData
   TestAssert "a sequence in an array", tData["list"][1] is 1
   TestAssert "a sequence in a sequence", tData["list"][2][2] is 3
   TestAssert "an array in an array", tData["map"]["x"]["y"] is "deep"
   TestAssert "an empty array in an array", the number of elements of tData["none"] is 0
end TestNested

on TestKeysAreExpressions
   local tKey, tKeyed
   put "colour" into tKey
   put {tKey: "red", tKey & "2": "blue", 3 + 4: "seven", (tKey): "again"} into tKeyed
   TestAssert "a key from a variable, given again", tKeyed["colour"] is "again"
   TestAssert "a key worked out", tKeyed["colour2"] is "blue"
   TestAssert "a number as a key", tKeyed[7] is "seven"
   TestAssert "three elements", the number of elements of tKeyed is 3
end TestKeysAreExpressions

on TestValuesAreExpressions
   local tX, tList
   put 5 into tX
   put [tX, tX * 2, "a" & "b", the number of chars of "abc", __Double(tX), -tX] into tList
   TestAssert "a variable", tList[1] is 5
   TestAssert "arithmetic", tList[2] is 10
   TestAssert "concatenation", tList[3] is "ab"
   TestAssert "a function of the engine", tList[4] is 3
   TestAssert "a handler of the script", tList[5] is 10
   TestAssert "a minus sign", tList[6] is -5
end TestValuesAreExpressions

private function __Double pValue
   return pValue * 2
end __Double

on TestColonBeforeASign
   -- the colon after a key is a token of its own, whatever follows it
   local tKeyed
   put {"a":-1, "b":"x", "c":(2)} into tKeyed
   TestAssert "a minus sign after the colon", tKeyed["a"] is -1
   TestAssert "a string after the colon", tKeyed["b"] is "x"
   TestAssert "brackets after the colon", tKeyed["c"] is 2
end TestColonBeforeASign

on TestDuplicateKeys
   local tKeyed
   put {"x": 1, "x": 2} into tKeyed
   TestAssert "a key given again gives the element its value", tKeyed["x"] is 2
   TestAssert "one element", the number of elements of tKeyed is 1
end TestDuplicateKeys

on TestCaseSensitive
   local tKeyed
   -- keys are compared as the caseSensitive says, as by "put" into an element
   set the caseSensitive to false
   put {"a": 1, "A": 2} into tKeyed
   TestAssert "one element when the caseSensitive is false", the number of elements of tKeyed is 1
   TestAssert "with the later value", tKeyed["a"] is 2
   set the caseSensitive to true
   put {"a": 1, "A": 2} into tKeyed
   TestAssert "two elements when the caseSensitive is true", the number of elements of tKeyed is 2
   set the caseSensitive to false
end TestCaseSensitive

on TestAFreshArrayEachTime
   -- a literal is worked out each time it is reached: what was put into
   -- the array it gave is not in the next one
   local tIndex, tList, tCounts
   repeat with tIndex = 1 to 3
      put [tIndex] into tList
      put "more" into tList[2]
      put the number of elements of tList after tCounts
      TestAssert "it holds this time's value" && tIndex, tList[1] is tIndex
   end repeat
   TestAssert "a new array each time", tCounts is "222"
end TestAFreshArrayEachTime

on TestWhereAnExpressionGoes
   local tTotal, tElement, tResult
   -- a parameter
   TestAssert "a function's parameter", __Count([1, 2, 3]) is 3
   __Remember {"a": 1}
   TestAssert "a command's parameter", the number of elements of the cRemembered of me is 1
   -- repeat for each
   repeat for each element tElement in [1, 2, 3]
      add tElement to tTotal
   end repeat
   TestAssert "repeat for each element", tTotal is 6
   -- a condition
   if {} is empty then
      put true into tResult
   end if
   TestAssert "in an if", tResult is true
   -- return
   put __Pair() into tResult
   TestAssert "a handler returns one", tResult[2] is "b"
   -- line continuation
   put {"one": 1, \
         "two": 2} into tResult
   TestAssert "across a continued line", tResult["two"] is 2
   set the cRemembered of me to empty
end TestWhereAnExpressionGoes

private function __Count pArray
   return the number of elements of pArray
end __Count

private command __Remember pArray
   set the cRemembered of me to pArray
end __Remember

private function __Pair
   return ["a", "b"]
end __Pair

on TestWithArrayOperations
   local tA, tB
   put {"a": 1, "b": 2} into tA
   union tA with {"c": 3}
   TestAssert "union with a literal", the number of elements of tA is 3
   put [1, 2, 3] into tB
   combine tB using comma
   TestAssert "combine a sequence", tB is "1,2,3"
end TestWithArrayOperations

on TestValueAndDo
   -- text given to value or do that did not compile before is worked out
   -- now, as a handler is
   local tList
   put value("[1, 2, 3]") into tList
   TestAssert "value of a sequence", tList[3] is 3
   do "put {" & quote & "k" & quote & ": 7} into tList"
   TestAssert "do with an array", tList["k"] is 7
end TestValueAndDo

on TestMergeAndSendKeepTheirText
   -- a merge template's [[...]] and <?...?>, and a parameter of send
   -- given as text, are worked out only if they compile, and left as text
   -- otherwise: a "[" or "{" there begins no literal array, so that wiki,
   -- JSON or JavaScript text in them is left as it was
   local tFoo
   put "x" into tFoo
   TestAssert "merge leaves [[[...]]] as it was", merge("[[[Foo]]]") is "[[[Foo]]]"
   TestAssert "and [[ [...] ]]", merge("[[ [tFoo] ]]") is "[[ [tFoo] ]]"
   TestAssert "and <?...?>", merge("<?return [1]?>") is "<?return [1]?>"
   TestAssert "and works out what compiles", merge("[[tFoo]] [[ [tFoo] ]]") is "x [[ [tFoo] ]]"
   send "LiteralReceived [1]" to me
   TestAssert "a parameter of send given as text is text", the result is "[1]"
   send "LiteralReceived {" & quote & "a" & quote & ": 1}" to me
   TestAssert "with braces too", the result is "{" & quote & "a" & quote & ": 1}"
end TestMergeAndSendKeepTheirText

on LiteralReceived pValue
   return pValue
end LiteralReceived

on TestBadKey
   TestAssertThrow "a key that is an array throws", "LiteralBadKey", \
         the long id of me, "EE_ARRAYLITERAL_BADKEY"
end TestBadKey

on LiteralBadKey
   get {[1]: 2}
end LiteralBadKey

on TestEmptyKey
   local tKeyed, tNone
   -- an empty key, or one that is an empty array, is the empty key, as in
   -- "put 1 into tKeyed[empty]"
   put {"": 1, tNone: 2, []: 3} into tKeyed
   TestAssert "one element", the number of elements of tKeyed is 1
   TestAssert "under the empty key", tKeyed[empty] is 3
end TestEmptyKey

on TestBadValue
   TestAssertThrow "a value whose expression throws throws", "LiteralBadValue", \
         the long id of me, "EE_PLUS_BADLEFT,EE_ARRAYLITERAL_BADVALUE"
end TestBadValue

on LiteralBadValue
   local tWord
   put "x" into tWord
   get [1, tWord + 1]
end LiteralBadValue

on TestAnElementIsWritten
   -- every element is written out: a comma with nothing before it is an
   -- error (in a list of parameters it would be an empty one), but a
   -- comma after the last element is not
   TestAssert "[,] is an error", __CompileError("get [,]") is not empty
   TestAssert "[1,,2] is an error", __CompileError("get [1,,2]") is not empty
   TestAssert "[,1] is an error", __CompileError("get [,1]") is not empty
   TestAssert "a key left out is an error", __CompileError("get {:1}") is not empty
   TestAssert "a value left out is an error", \
         __CompileError("get {" & quote & "a" & quote & ":, " & quote & "b" & quote & ": 1}") is not empty
   TestAssert "[1,] is no error", __CompileError("get [1,]") is empty
end TestAnElementIsWritten

-- What compiled before compiles as it did: a square bracket after a
-- variable is still its key, with or without a space

on TestKeysOfVariablesAsBefore
   local tA, tB
   put "first" into tA[1]
   put tA [1] into tB
   TestAssert "a variable, a space and a key", tB is "first"
   TestAssert "a variable and a key", tA[1] is "first"
end TestKeysOfVariablesAsBefore

-- A handler that compiles neither way reports the error it reported
-- before, as one with the microseconds or matches does: where the reading
-- without literals failed. With a literal on line 2 and a mistake on line
-- 3, that is line 2, the literal's, not line 3, where the reading with
-- literals fails

on TestCompileErrors
   local tError
   put __CompileError("put [1, 2] into tX" & return & "put 1 1 into tX") into tError
   TestDiagnostic tError
   TestAssert "the error is where the first reading failed", item 2 of tError is 2
   put __CompileError("put {" & quote & "a" & quote & ": 1} into tX" & return & "put 1 1 into tX") into tError
   TestAssert "with a literal of keys and values too", item 2 of tError is 2
   put __CompileError("put [1, 2 into tX") into tError
   TestAssert "a literal left open is an error", tError is not empty
   TestAssert "on its line", item 2 of tError is 2
   put __CompileError("put 1 1 into tX") into tError
   TestAssert "a mistake with no literal is reported where it was", item 2 of tError is 2
end TestCompileErrors

-- The error a handler holding pLines gives as it compiles (its first
-- line: the code, line and column), or empty
private function __CompileError pLines
   local tButton, tError
   lock messages
   create button "OXTLiteralProbe"
   put it into tButton
   set the script of tButton to "on probe" & return & pLines & return & "end probe"
   put line 1 of the result into tError
   delete tButton
   unlock messages
   return tError
end __CompileError
