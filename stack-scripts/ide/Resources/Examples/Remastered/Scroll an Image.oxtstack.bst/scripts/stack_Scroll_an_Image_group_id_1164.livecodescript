script "stack_Scroll_an_Image_group_id_1164"
-- Stack file: ide/Resources/Examples/Remastered/Scroll an Image.oxtstack
-- Object: stack "Scroll an Image" > card "Controls Scroll Too" (id 1032) > group "Find the button" (id 1164)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(added in the remaster) Scrolls the group
--until the button is in its window: its
--hScroll goes up by as much as the
--button's right edge is past the window's.

on mouseUp
   local tGroup, tPast
   put the long id of group "Controls" into tGroup
   --(the window ends where the group's
   --vertical scrollbar begins)
   put the right of button "Test Button" + 8 - (the right of tGroup - the scrollbarWidth of tGroup) into tPast
   lock screen
   if tPast > 0 then set the hScroll of tGroup to the hScroll of tGroup + tPast
   set the vScroll of tGroup to 0
   unlock screen
end mouseUp
