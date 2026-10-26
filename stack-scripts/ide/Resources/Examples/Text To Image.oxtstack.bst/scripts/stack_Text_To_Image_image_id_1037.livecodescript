script "stack_Text_To_Image_image_id_1037"
-- Stack file: ide/Resources/Examples/Text To Image.oxtstack
-- Object: stack "Text To Image" > card (id 1002) > image "Info" (id 1037)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
  set the ink of me to "srcCopy"  --default
  set the scroll of fld "Info" to "0"
  set the visible of fld "Info" to not the visible of fld "Info"
end mouseup

on mousedown
  set the ink of me to "blendBurn"  --simulate btn hilite
end mousedown

on mouserelease
  set the ink of me to "srcCopy"  --default
end mouserelease
