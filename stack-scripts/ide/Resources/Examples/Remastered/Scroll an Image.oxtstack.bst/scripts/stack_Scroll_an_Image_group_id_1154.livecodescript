script "stack_Scroll_an_Image_group_id_1154"
-- Stack file: ide/Resources/Examples/Remastered/Scroll an Image.oxtstack
-- Object: stack "Scroll an Image" > card "Controls Scroll Too" (id 1032) > group "Controls" (id 1154)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(added in the remaster) This group
--scrolls as the group "Display" on the
--card before does: scrollbarDrag shows
--where it is, in the header.

on scrollbarDrag
   put the hScroll of me into field "HValue"
   put the vScroll of me into field "VValue"
end scrollbarDrag
