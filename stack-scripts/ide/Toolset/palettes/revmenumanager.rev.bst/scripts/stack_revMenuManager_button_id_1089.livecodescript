script "stack_revMenuManager_button_id_1089"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Windows Preview" (id 5351) > button "Preview" (id 1089)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--setprop cREVLabel pLabel
--  global gREVActiveMenuButton
--  switch
--  case pLabel is empty
--    set the label of me to empty
--    break
--  case comma is in the effective textFont of gREVActiveMenuButton
--    set the label of me to uniEncode("Preview ") & uniEncode("(") \
      --        & uniEncode(quote) & pLabel & uniEncode(quote) & uniEncode(" Menu)") 
--    break
--  default
--    set the label of me to "Preview" && "(" & quote & pLabel & quote && "Menu)"
--    break
--  end switch
--  set the rect of me to the topLeft of me, the left of me + the formattedWidth of me, \
      --      the bottom of me
--  set the left of grc "Preview Border 1" to the right of me + 2
--  set the left of grc "Preview Border 2" to the right of me + 3
--end cREVLabel

setprop cREVLabel pLabel
   global gREVActiveMenuButton
   switch
      case pLabel is empty
         set the label of me to empty
         break
      default
         set the unicodelabel of me to uniEncode("Preview ") & uniEncode("(") \
               & uniEncode(quote) & pLabel & uniEncode(quote) & uniEncode(" Menu)") 
         break
   end switch
   set the rect of me to the topLeft of me, the left of me + the formattedWidth of me, \
         the bottom of me
   set the left of grc "Preview Border 1" to the right of me + 2
   set the left of grc "Preview Border 2" to the right of me + 3
end cREVLabel
