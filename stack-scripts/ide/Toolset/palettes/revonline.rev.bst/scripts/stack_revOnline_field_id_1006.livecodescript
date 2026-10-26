script "stack_revOnline_field_id_1006"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007) > field "tags" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tLine
   put word 2 of the mouseLine into tLine
   if the mousetext is not empty then
      set the cSelectedTag of the long owner of me to line tLine of the text of me
      # hack
      send "clearStyles" to field "tags" of group "viewing pane" of this stack
      --send "clearColors" to field "tags" of group "viewing pane" of this stack
   end if
end mouseUp

on mouseMove
   local tLine
   get the mouseLine
   put word 2 of it into tLine
   hiliteHoverText tLine, (the long id of me)
end mouseMove

on mouseLeave
   clearColors (the long id of me)
end mouseLeave

# To combat strange scrolling field when no target bug
# To reproduce bug, remove this handler and use scrollwheel
# when mouse is over the background graphic of the menubar
on rawkeydown pKey
   local tScrollValue
   put round(the formattedheight of me / 20) into tScrollValue
   if pKey is 65308 then
      if the mousecontrol is not empty then
         if the long id of the mousecontrol is the long id of me then
            resetUpArrowIcon
            set the icon of button "down" of the owner of me to 205360
            send "resetDownArrowIcon" to me in 600 milliseconds            
            set the vScroll of me to (the vScroll of me + tScrollValue)
            --pass rawKeyDown
         end if
      end if
   else if pKey is 65309 then
      if the mousecontrol is not empty then
         if the long id of the mousecontrol is the long id of me then
            resetDownArrowIcon
            set the icon of button "up" of the owner of me to 205362
            send "resetUpArrowIcon" to me in 600 milliseconds
            set the vScroll of me to (the vScroll of me - tScrollValue)
            --pass rawKeyDown
         end if
      end if
   else
      pass rawKeyDown
   end if
end rawkeydown

command resetUpArrowIcon
   set the icon of button "up" of the owner of me to 205337
end resetUpArrowIcon

command resetDownArrowIcon
   set the icon of button "down" of the owner of me to 205338
end resetDownArrowIcon
