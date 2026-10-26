script "stack_Page_Setup_card_id_1001"
-- Stack file: ide/Toolset/palettes/revpagesetup.rev
-- Object: stack "Page Setup" > card "Print Setup Card" (id 1001)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

function cn fieldname
  if field fieldname is not a number or field fieldname < 0 then
    beep 1
    select text of field fieldname
    return true
  end if
  return false
end cn

on setprops
  local pwidth, pheight, swidth, sheight, pscale
  if cn("Top") or cn("Bottom") or cn("Left") or cn("Right")
  then exit to MetaCard
  send "setMargins" to group "Units"
  if cn("Scale")
  then exit to MetaCard
  if the printRotated then
    put item 1 of the the printPaperSize into pheight
    put item 2 of the the printPaperSize into pwidth
  else
    put item 1 of the the printPaperSize into pwidth
    put item 2 of the the printPaperSize into pheight
  end if
  subtract item 1 of the printMargins + item 3 of the printMargins from pwidth
  subtract item 2 of the printMargins + item 4 of the printMargins from pheight
  put the width of stack (the short name of button id 1109) into swidth
  put the height of stack (the short name of button id 1109) into sheight
  if the hilite of button "Pack Horizontally" then
    subtract (field "Scale" - 1) * item 2 of the printGutters from pwidth
    put pwidth / (swidth * field "Scale") into pscale
    if sheight * pscale > pheight
    then set the printScale to pheight / sheight
    else set the printScale to pscale
  else
    subtract (field "Scale" - 1) * item 1 of the printGutters from pheight
    put pheight / (sheight * field "Scale") into pscale
    if swidth * pscale > pwidth
    then set the printScale to pwidth / swidth
    else set the printScale to pscale
  end if
  set the printCardBorders to the hilite of button "Print Card Borders"
  set the printColors to the hilite of button "Color"
  close this stack
end setprops

on preOpenCard
  local sname, c
  put the short name of the topStack into sname
  set the name of button id 1109 to sname
  send "loadMargins" to group "Units"
  send "resetMargins" to group "Units"
  set the hilite of button "Print Card Borders" to the printCardBorders
  set the hilite of button "Color" to the printColors
  set the hilite of button "Black and White" to not the printColors
end preOpenCard
