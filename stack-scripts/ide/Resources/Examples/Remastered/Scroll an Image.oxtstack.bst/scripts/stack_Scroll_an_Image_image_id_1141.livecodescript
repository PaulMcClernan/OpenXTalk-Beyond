script "stack_Scroll_an_Image_image_id_1141"
-- Stack file: ide/Resources/Examples/Remastered/Scroll an Image.oxtstack
-- Object: stack "Scroll an Image" > card "The Painting" (id 1031) > image "Map" (id 1141)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(added in the remaster) The whole
--painting, small: click or drag in it to
--choose what the group "Display" shows.

on mouseDown
   lookAt the mouseH, the mouseV
   --so that the panel beside the stage
   --shows this script
   pass mouseDown
end mouseDown

on mouseMove pX, pY
   if the mouse is down then lookAt pX, pY
end mouseMove

--scrolls the group so that the point pX,pY
--of the small copy is in the middle of its
--window
command lookAt pX, pY
   local tScale, tWide, tHigh
   put the width of me / the formattedWidth of image "ElGreco.jpg" into tScale
   --the window, less its scrollbar
   put the width of group "Display" - the scrollbarWidth of group "Display" into tWide
   put the height of group "Display" - the scrollbarWidth of group "Display" into tHigh
   lock screen
   --(the group keeps them in its range)
   set the hScroll of group "Display" to round((pX - the left of me) / tScale - tWide / 2)
   set the vScroll of group "Display" to round((pY - the top of me) / tScale - tHigh / 2)
   unlock screen
end lookAt
