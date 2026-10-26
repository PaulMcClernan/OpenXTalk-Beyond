script "stack_revGettingStartedScripts_group_id_1052"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Text Menu: updating check marks Example" (id 1052)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenBackground
  set the textFont of field "Example Text" to empty
  set the textColor of field "Example Text" to empty
end preOpenBackground
 
on openBackGround
  put "9,10,12,14,18,20,24,36" into theSizes
  put "Black,Yellow,Red,Blue,Green" into theColors
  -- set up the Font submenu:
  get the fontNames
  sort it
  put "Font" into button "Text"
  repeat for each line thisFont in it
    put return & tab & thisFont after button "Text"
  end repeat
  -- set up the Size submenu:
  put return & "Size" after button "Text"
  repeat for each item thisSize in theSizes
    put return & tab & thisSize after button "Text"
  end repeat
  -- set up the Color submenu:
  put return & "Color" after button "Text"
  repeat for each item thisColor in theColors
    put return & tab & thisColor after button "Text"
  end repeat
  -- set up style choices:
  put return & "(-" & return \
      & "Plain" & return \
      & "Bold" & return \
      & "Italic" & return \
      & "Underline" after button "Text"
end openBackGround
