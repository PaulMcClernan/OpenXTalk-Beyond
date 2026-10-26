script "stack_SQLite_Books"
-- Stack file: ide/Resources/Examples/Remastered/SQLite Books.oxtstack
-- Object: stack "SQLite Books"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--SQLite Books: SQLite Book Library, one of OpenXTalk Lite's demos, remastered for OXT-Beyond in 2026
--(its author is not recorded)

--The library's handlers (preOpenStack, dbListAll, dbSearch, AddRecord and DeleteRecord) were in this
--stack script: they are in the script of the card "Library" now, so that the panel beside its stage
--shows them, and its preOpenStack is that card's preOpenCard.

on openStack  --added: a word, if the IDE's data grid library is not there to draw the grid
   if there is not a stack "revDataGridLibrary" then
      answer "The data grid on the Library card needs the IDE's data grid library, and it is not loaded." &cr& \
            "In Preferences, under Compatibility, untick Disable Data Grids, then start the IDE again." with "OK" titled "SQLite Books"
   end if
   pass openStack
end openStack

on preOpenCard  --added: the code on the card in the scripts panel's font (the web IDE, say, has Droid Sans Mono and not Source Code Pro)
   local tFont, tIndex, tField
   put codeFontHere() into tFont
   if tFont is not empty then
      repeat with tIndex = 1 to the number of fields of this card
         put the long id of field tIndex of this card into tField
         if the cCode of tField is true and the textFont of tField is not tFont then set the textFont of tField to tFont
      end repeat
   end if
   pass preOpenCard
end preOpenCard

function codeFontHere  --added: code's font, the scripts panel's (the window finds it before this stack's preOpenCard), or else the first of its choices this computer has
   local tFont
   if there is a field "codeText" then
      if the textFont of field "codeText" is not empty then return the textFont of field "codeText"
   end if
   repeat for each item tFont in "Source Code Pro,Droid Sans Mono,Menlo,Consolas,DejaVu Sans Mono,Courier New"
      if tFont is among the lines of the fontNames then return tFont
   end repeat
   return empty
end codeFontHere
