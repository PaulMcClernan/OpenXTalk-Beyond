script "stack_mobileTemplate_button_id_1889"
-- Stack file: ide/Resources/Start Center/samples/sample_3/mobileTemplate.livecode
-- Object: stack "mobileTemplate" > card "template" (id 1868) > button "theme" (id 1889)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   local tColor
   
   switch tolower(pItemName)
      case "custom"
         put field "color" into tColor
         if the number of items of tColor is 3 then
            set the theme of this stack to tColor
         end if
         break
         
      default
         set the theme of this stack to pItemName
   end switch
end menuPick
