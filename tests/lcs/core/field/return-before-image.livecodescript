script "CoreFieldReturnBeforeImage"
-- OXT-Beyond: a return put before a char that shows an image (its
-- imageSource) splits the paragraph at the start of the char's block. The
-- engine trimmed that block to nothing before it copied it for the new
-- paragraph, and a block with an image that is trimmed to nothing frees
-- all its attributes, so the char lost its imageSource, and its colour,
-- style, link and metadata with it (tperry2x, openxtalk.org p=25422).
-- Here it keeps them, whether a script puts the return or the user types
-- it, and a split anywhere else is as it was: a char with no image keeps
-- its attributes, an image on two chars splits into two, and the empty
-- paragraph left in front shows no image. Copied text is cut out of its
-- paragraph the same way, so the undo of a deletion that started with
-- such a char brought the char back without its image, as did the undo of
-- a deleted return in front of one.

-- The htmlText pText with each ' made a quote
private function q pText
   replace "'" with quote in pText
   return pText
end q

-- A field "Test" in a new stack "TestStack" with the text "abc", and an
-- image "Arrow" there: the image's id
private function setUpField
   create stack "TestStack"
   set the defaultStack to "TestStack"
   create image "Arrow"
   create field "Test"
   put "abc" into field "Test"
   return the id of image "Arrow"
end setUpField

on TestTeardown
   if there is a stack "TestStack" then delete stack "TestStack"
end TestTeardown

on TestReturnBeforeFirstCharImage
   local tID
   put setUpField() into tID
   set the imageSource of char 1 of field "Test" to tID
   put return before char 1 of field "Test"
   TestAssert "the text has the return first", the text of field "Test" is (return & "abc")
   TestAssert "the char after the return keeps its image", the imageSource of char 2 of field "Test" is tID
   TestAssert "the empty paragraph shows no image", \
         the htmlText of field "Test" is q("<p></p>" & return & "<p><img src='" & tID & "' char='a'>bc</p>")
   delete char 1 of field "Test"
   TestAssert "deleting the return again leaves the image where it was", \
         the htmlText of field "Test" is q("<p><img src='" & tID & "' char='a'>bc</p>")
end TestReturnBeforeFirstCharImage

on TestReturnBeforeImageInParagraph
   local tID
   put setUpField() into tID
   set the imageSource of char 2 of field "Test" to tID
   put return before char 2 of field "Test"
   TestAssert "the image moves to the new paragraph", the imageSource of char 3 of field "Test" is tID
   TestAssert "the char before the return has no image", the imageSource of char 1 of field "Test" is empty
   TestAssert "the htmlText has the image in the second paragraph", \
         the htmlText of field "Test" is q("<p>a</p>" & return & "<p><img src='" & tID & "' char='b'>c</p>")
end TestReturnBeforeImageInParagraph

on TestReturnBetweenImages
   local tID
   put setUpField() into tID
   set the imageSource of char 1 of field "Test" to tID
   set the imageSource of char 2 of field "Test" to tID
   put return after char 1 of field "Test"
   TestAssert "the first image stays", the imageSource of char 1 of field "Test" is tID
   TestAssert "the second image moves with its char", the imageSource of char 3 of field "Test" is tID
end TestReturnBetweenImages

on TestReturnBeforeImageKeepsStyles
   local tID
   put setUpField() into tID
   set the imageSource of char 1 of field "Test" to tID
   set the textColor of char 1 of field "Test" to "255,0,0"
   set the textStyle of char 1 of field "Test" to "bold"
   set the linkText of char 1 of field "Test" to "L"
   set the metadata of char 1 of field "Test" to "M"
   put return before char 1 of field "Test"
   TestAssert "the image stays", the imageSource of char 2 of field "Test" is tID
   TestAssert "the colour stays", the textColor of char 2 of field "Test" is "255,0,0"
   TestAssert "the style stays", the textStyle of char 2 of field "Test" is "bold"
   TestAssert "the link stays", the linkText of char 2 of field "Test" is "L"
   TestAssert "the metadata stays", the metadata of char 2 of field "Test" is "M"
end TestReturnBeforeImageKeepsStyles

-- As before the change: a char with no image keeps its attributes, and an
-- image on two chars that a return splits stays on both
on TestReturnSplitsAsBefore
   local tID
   put setUpField() into tID
   set the textColor of char 1 of field "Test" to "255,0,0"
   set the linkText of char 1 of field "Test" to "L"
   put return before char 1 of field "Test"
   TestAssert "a char with no image keeps its colour", the textColor of char 2 of field "Test" is "255,0,0"
   TestAssert "a char with no image keeps its link", the linkText of char 2 of field "Test" is "L"
   put "abc" into field "Test"
   set the imageSource of char 1 to 2 of field "Test" to tID
   put return after char 1 of field "Test"
   TestAssert "an image on two chars stays on both halves", \
         the htmlText of field "Test" is q("<p><img src='" & tID & "' char='a'></p>" & return & "<p><img src='" & tID & "' char='b'>c</p>")
end TestReturnSplitsAsBefore

-- The user types the return, in front of the image
on TestTypeReturnBeforeImage
   TestSkipIfNot "wait"
   local tID
   put setUpField() into tID
   set the imageSource of char 1 of field "Test" to tID
   select before char 1 of field "Test"
   type return
   TestAssert "a typed return leaves the image on its char", the imageSource of char 2 of field "Test" is tID
   TestAssert "a typed return puts the return first", the text of field "Test" is (return & "abc")
end TestTypeReturnBeforeImage

-- The user deletes text that starts with the char, then undoes it: the
-- deletion's undo record is a copy of the text deleted
on TestUndoDeletionBringsImageBack
   TestSkipIfNot "wait"
   local tID
   put setUpField() into tID
   set the imageSource of char 2 of field "Test" to tID
   select char 2 to 3 of field "Test"
   type numToChar(8)
   TestAssert "the deletion leaves the first char", the text of field "Test" is "a"
   undo
   TestAssert "undoing the deletion brings the image back", the imageSource of char 2 of field "Test" is tID
   TestAssert "undoing the deletion brings the text back as it was", \
         the htmlText of field "Test" is q("<p>a<img src='" & tID & "' char='b'>c</p>")
end TestUndoDeletionBringsImageBack

-- The user deletes the return in front of the char, joining two lines,
-- then undoes it: the undo splits the line again in front of the char
on TestUndoJoinKeepsImage
   TestSkipIfNot "wait"
   local tID
   put setUpField() into tID
   put "ab" & return & "c" into field "Test"
   set the imageSource of char 4 of field "Test" to tID
   select before char 4 of field "Test"
   type numToChar(8)
   TestAssert "the deletion joins the lines", the text of field "Test" is "abc"
   TestAssert "the joined line keeps the image", the imageSource of char 3 of field "Test" is tID
   undo
   TestAssert "undoing the join splits the lines again", the text of field "Test" is ("ab" & return & "c")
   TestAssert "undoing the join leaves the image on its char", the imageSource of char 4 of field "Test" is tID
end TestUndoJoinKeepsImage
