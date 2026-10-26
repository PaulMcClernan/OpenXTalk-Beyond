script "stack_revGettingStartedScripts_button_id_1004"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Displaying a count down (blocking) Example" (id 1003) > button "Example" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put 99 into bottlesLeft
  repeat until the mouseClick -- stop song when the user clicks
    -- show a verse, using the bottlePhrase function
    -- do one verse on each iteration of the loop:
    switch bottlesLeft
    case zero -- last verse, zero bottles left
      put bottlePhrase(bottlesLeft) && "on the wall," \
         && toLower(bottlePhrase(bottlesLeft)) & return \
         & "Go to the store and buy some more," \
         && toLower(bottlePhrase(99)) \
         && "on the wall." into field "Song"
      break 
    default -- all other verses
      put bottlePhrase(bottlesLeft) && "on the wall," \
         && toLower(bottlePhrase(bottlesLeft)) & return \
         & "Take one down and pass it around," \
         && toLower(bottlePhrase(bottlesLeft - 1)) \
         && "on the wall." into field "Song"
    end switch
    subtract 1 from bottlesLeft -- for the next verse
    if bottlesLeft < zero then put 99 into bottlesLeft
    wait for 1 second
  end repeat
  -- when the repeat loop ends with a click, the song is over:
  put empty into field "Song"
end mouseUp

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
