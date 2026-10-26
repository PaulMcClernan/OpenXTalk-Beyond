script "stack_Scroll_an_Image_group_id_1135"
-- Stack file: ide/Resources/Examples/Remastered/Scroll an Image.oxtstack
-- Object: stack "Scroll an Image" > card "The Painting" (id 1031) > group "Display" (id 1135)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(added in the remaster) A group gets the
--message scrollbarDrag each time it
--scrolls: when its scrollbars are dragged,
--when the wheel turns, and when a script
--sets its hScroll or vScroll. Here it
--shows where it is: the numbers in the
--header, and the frame on the small copy.

on scrollbarDrag
   local tScale
   --how far it is scrolled to the right,
   --and how far down, in pixels
   put the hScroll of me into field "HValue"
   put the vScroll of me into field "VValue"
   --the small copy's size, to the painting
   put the width of image "Map" / the formattedWidth of image "ElGreco.jpg" into tScale
   set the topLeft of graphic "View" to the left of image "Map" + round(the hScroll of me * tScale), \
         the top of image "Map" + round(the vScroll of me * tScale)
end scrollbarDrag
