script "stack_revImageLibrary"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeStack
   local tWidth, tHeight, tButtonWidth, tButtonHeight, tTop, tLeft, tX, tY
  if the number of this cd is 2 then
    set the rect of group "images in library" to 42,106,the width of this stack - 40,the height of this stack - 90
    set the rect of sb 1 to the width of this stack -60,106,the width of this stack -40,the height of this stack - 112
    put the width of group "images in library" - 25 into tWidth
    put the height of group "images in library" - 14 into tHeight
    put round((tWidth-5) / 10) into tButtonWidth
    put round(tHeight/ 3) -2 into tButtonHeight
    put the top of group "images in library" into tTop
    put the left of group "images in library" + 2 into tLeft
    put 0 into tY
    put 0 into tX
    repeat with i = 1 to the number of btns in group "images in library"
      set the width of btn i of group "images in library" to tButtonWidth
      set the height of btn i of group "images in library" to tButtonHeight
      set the left of btn i of group "images in library" to tLeft + (tX * tButtonWidth)
      set the top of btn i of group "images in library" to tTop + (tY * tButtonHeight)
      if i is 10 then
        put 1 into tY
        put 0 into tX
      else if i is 20 then
        put 2 into tY
        put 0 into tX
      else
        add 1 to tX
      end if
    end repeat
    if the loc of grc "marquee" is not -200,-200 and exists(the cObject of grc "marquee") then set the rect of grc "marquee" to the rect of the cObject of grc "Marquee"
  end if
  revUpdateGeometry
end resizeStack

on openCard
  resizeStack
end openCard

on preOpenStack
   -- text fonts and size
   set the textFont of button "Tabs" of card 1 to empty
   set the textSize of button "Tabs" of card 1 to 13
end preOpenStack
