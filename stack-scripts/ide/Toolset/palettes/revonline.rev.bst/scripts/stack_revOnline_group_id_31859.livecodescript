script "stack_revOnline_group_id_31859"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kGroupList = "user,stack"
local sViewType

command initialize
   --send "initialize" to group "stack" of me
end initialize

# Need to do some pref saving/loading here too
# pView : user, upload content, stack, login
setProp cViewType pView
   put pView into sViewType
   repeat for each item tGroup in kGroupList
      if tGroup is pView then
         show group tGroup of me
      else
         hide group tGroup of me
      end if
   end repeat
   set the vScroll of me to 0
   updateScrollbar
end cViewType

getProp cViewType
   return sViewType
end cViewType

command updateScrollbar
   local tId
   put the long id of me into tId
   set the cControl of group "viewing pane scrollbar" to tId
   send "update" to group "viewing pane scrollbar"
end updateScrollbar

command resize
   local tRect
   put the rect of me into tRect
   
   if the visible of group "stack" of me then
      send "resize tRect" to group "stack" of me
      if the vScroll of me is 0 then
         set the rect of group "stack" of me to \
                (the left of me, the top of me, the right of me-25, the top of group "stack" of me + the formattedheight of group "stack" of me + 5)
      else
         set the rect of group "stack" of me to \
                (the left of me, the top of group "stack" of me, the right of me-25, the top of group "stack" of me + the formattedheight of group "stack" of me + 5)
      end if
      set the rect of graphic "message catcher" of me to the rect of group "stack" of me
   end if
   
   if the visible of group "user" of me then
      send "resize tRect" to group "user" of me
      if the vScroll of me is 0 then
         set the rect of group "user" of me to \
                (the left of me, the top of me, the right of me-25, the top of group "user" of me + the formattedheight of group "user" of me + 5)
      else
         set the rect of group "user" of me to \
                (the left of me, the top of group "user" of me, the right of me-25, the top of group "user" of me + the formattedheight of group "user" of me + 5)
      end if
      set the rect of graphic "message catcher" of me to the rect of group "user" of me
   end if   
   updateScrollbar   
end resize

on rawkeydown pKey
   if pKey is 65308 then
      scrollUp
   else if pKey is 65309 then
      scrollDown
   else
      pass rawkeydown
   end if
end rawkeydown


command scrollUp
   lock screen
   local tScrollValue
   put round(the formattedheight of me / 20) into tScrollValue
   set the vScroll of me to (the vScroll of me + tScrollValue)
   updateScrollbar
   unlock screen
end scrollUp

command scrollDown
   lock screen
   local tScrollValue
   put round(the formattedheight of me / 20) into tScrollValue
   set the vScroll of me to (the vScroll of me - tScrollValue)
   updateScrollbar
   unlock screen
end scrollDown
