script "stack_Text_To_Image_button_id_1071"
-- Stack file: ide/Resources/Examples/Text To Image.oxtstack
-- Object: stack "Text To Image" > card (id 1002) > button "Create Image" (id 1071)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --make text image.png
   if fld "Display" = empty then
      answer "Please enter some text to create an image." with "OK"
      select text of fld "Display"
      exit to top
   end if
   put the opaque of fld "Display" into OldOpaque
   put the showBorder of fld "Display" into OldBorder
   set the opaque of fld "Display" to "false"
   set the showBorder of fld "Display" to "false"
   set the defaultStack to the topstack
   export snapshot from fld "Display" to ImgData as PNG
   put getName() into ImgName
   lock screen
   if there is no img ImgName then create img ImgName
   set the loc of img ImgName to the loc of this cd
   set the text of img ImgName to ImgData
   set the dropShadow["color"] of img ImgName to "black"
   set the dropShadow["opacity"] of img ImgName to "150"
   set the opaque of fld "Display" to OldOpaque
   set the showBorder of fld "Display" to OldBorder
   set the rect of fld "Display" to "4,6,439,65"
   select last img
end mouseUp

function getName
   put  "TextImg1" into NewName
   repeat until there is no img NewName 
     add 1 to last char of NewName
   end repeat
   return NewName
end getName
