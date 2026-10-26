script "stack_revOnline_button_id_864944"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007) > button "up" (id 864944)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sScroll

on mouseEnter
   put true into sScroll
   scrollUp
end mouseEnter

command scrollUp
   if sScroll is true then
      local tScrollAmount
      put round(((the formattedheight of field "tags" of group "search filter" of stack "revonline") / (the height of field "tags" of group "search filter" of stack "revonline"))) into tScrollAmount
      set the vscroll of field "tags" of group "search filter" of this stack to the vscroll of field "tags" of group "search filter" of this stack - tScrollAmount
      send "scrollUp" to me in 3 milliseconds
   end if
end scrollUp

on mouseLeave
   put false into sScroll
end mouseLeave
