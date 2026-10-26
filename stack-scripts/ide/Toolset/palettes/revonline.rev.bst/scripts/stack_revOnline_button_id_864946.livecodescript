script "stack_revOnline_button_id_864946"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007) > button "down" (id 864946)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sScroll

on mouseEnter
   put true into sScroll
   scrollDown
   --set the vscroll of field "tags" of group "search filter" of this stack to the vscroll of field "tags" of group "search filter" of this stack + 1
end mouseEnter

command scrollDown
   if sScroll is true then
      local tScrollAmount
      put round((the formattedheight of field "tags" of group "search filter" of stack "revonline") / 1000) into tScrollAmount
      set the vscroll of field "tags" of group "search filter" of stack "revonline" to the vscroll of field "tags" of group "search filter" of stack "revonline" + tScrollAmount
      --put the vscroll of field "tags" of group "search filter" of this stack & ":" && the height of field "tags" of group "search filter" of this stack
      send "scrollDown" to me in 3 milliseconds
   end if
end scrollDown

on mouseLeave
   put false into sScroll
end mouseLeave
