script "stack_Page_Setup_group_id_1118"
-- Stack file: ide/Toolset/palettes/revpagesetup.rev
-- Object: stack "Page Setup" > card "Print Setup Card" (id 1001) > group "Margins" (id 1135) > group "Units" (id 1118)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local pmargins, pgutters

on loadMargins
  put the printMargins into pmargins
  put the printGutters into pgutters
end loadMargins

on resetMargins
  local factor
  put 1 into factor
  if the hilite of button "inches" then put 72 into factor
  if the hilite of button "centimetres" then put 72/2.54 into factor
  put item 1 of pmargins / factor into field "Left"
  put item 2 of pmargins / factor into field "Top"
  put item 3 of pmargins / factor into field "Right"
  put item 4 of pmargins / factor into field "Bottom"
  put item 1 of pgutters / factor into field "Row"
  put item 2 of pgutters / factor into field "Column"
end resetMargins

on getMargins
  local factor, lmargin, tmargin, rmargin, bmargin, rgutter, cgutter
  put 1 into factor
  if the hilitedButton of group "Units" is 1
  then put 72 into factor
  if the hilitedButton of group "Units" is 2
  then put 72/2.54 into factor
  put round(field "Left" * factor) into lmargin
  put round(field "Top" * factor) into tmargin
  put round(field "Right" * factor) into rmargin
  put round(field "Bottom" * factor) into bmargin
  put lmargin, tmargin, rmargin, bmargin into pmargins
  put round(field "Row" * factor) into rgutter
  put round(field "Column" * factor) into cgutter
  put rgutter,cgutter into pgutters
end getMargins

on setMargins
  getMargins
  set the printMargins to pmargins
  set the printGutters to pgutters
end setMargins

on focusIn
  getMargins
end focusIn

on mouseUp
  local bname
  put the short name of the target into bname
  if bname is "inches" or bname is "centimetres" or bname is "points" then resetMargins
end mouseUp
