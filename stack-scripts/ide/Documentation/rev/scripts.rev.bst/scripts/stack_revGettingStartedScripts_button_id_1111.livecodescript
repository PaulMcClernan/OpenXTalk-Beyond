script "stack_revGettingStartedScripts_button_id_1111"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Converting between characters and numerical (ASCII) values Example" (id 1110) > button "Convert" (id 1111)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  convertChar
  if the result is not empty then answer the result
end mouseUp

on convertChar conversionType
  if conversionType is empty then
    -- figure out which direction to convert:
    if field "Character" is not empty
    then put "character" into conversionType
    else put "ASCII" into conversionType
  end if
  if field conversionType is empty
  then return "Error: nothing to convert!"
  -- do the conversion:
  if conversionType is "character" then
    -- convert character to ASCII:
    put charToNum(char 1 of field "Character") into field "ASCII"
  else -- convert ASCII value to character:
    get field "ASCII"
    if (it is not an integer) or (it > 255) or (it < zero) then
      -- invalid character:
      return "Error: ASCII values are between 0 and 255."
      put empty into field "Character"
      select text of field "ASCII"
    else if (it <= 32) or (it = 127) then
      -- non-printable character:
      put item 2 of line it + 1 of the asciiChart of me \
          into field "Character"
    else -- ordinary character:
      put numToChar(it) into field "Character"
    end if
  end if
end convertChar
