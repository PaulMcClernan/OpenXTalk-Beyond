script "stack_revResourceCenter_button_id_579893"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Displayingacountdown(non-blocking)" (id 80215) > group "mainContent" (id 80225) > group (id 584269) > group "Example" (id 577046) > button "Example" (id 579893)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant startBottles = 99
local bottlesLeft = 99
local currentVerseMessage -- stores message ID so we can cancel

on mouseUp
  if currentVerseMessage is empty then -- song hasn't started
    displayCurrentVerse -- start the song
  else -- song is already going, so stop it
    cancel currentVerseMessage
    put empty into currentVerseMessage
    put empty into field "Song"
  end if
end mouseUp

on displayCurrentVerse
  if not (there is a field "song") then exit displayCurrentVerse -- card changed
  -- show a verse, using the bottlePhrase function,
  -- and set up the variable for the next verse
  switch bottlesLeft
  case zero -- last verse, zero bottles left
    put bottlePhrase(bottlesLeft) && "on the wall," \
        && toLower(bottlePhrase(bottlesLeft)) & return \
        & "You go to the store and buy some more," \ 
        && toLower(bottlePhrase(startBottles)) \
        && "on the wall!" into field "Song"
    put startBottles into bottlesLeft -- start again
    break
  default -- all other verses
    put bottlePhrase(bottlesLeft) && "on the wall," \
        && toLower(bottlePhrase(bottlesLeft)) & return \
        & "You take one down and pass it around," \
        && toLower(bottlePhrase(bottlesLeft - 1)) \
        && "on the wall!" into field "Song"
    subtract 1 from bottlesLeft -- for the next verse
  end switch
  send "displayCurrentVerse" to me in 1 second
  put the result into currentVerseMessage
end displayCurrentVerse

function bottlePhrase theNumber
  -- generate the "base phrase" used to make a verse
  switch theNumber
  case zero
    return "No more bottles of beer"
    break
  case one
    return "One last bottle of beer"
    break
  default
    return theNumber && "bottles of beer"
  end switch
end bottlePhrase
