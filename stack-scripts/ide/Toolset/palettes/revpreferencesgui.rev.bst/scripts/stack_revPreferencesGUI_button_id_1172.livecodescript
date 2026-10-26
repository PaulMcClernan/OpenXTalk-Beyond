script "stack_revPreferencesGUI_button_id_1172"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Debug Background Color" (id 1172)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   if pItemName contains "White" then
      set the cColor of me to 255,255,255
   end if
   if pItemName contains "Black" then
      set the cColor of me to 0,0,0
   end if
   if pItemName is "Cobalt" then
      set the cColor of me to 31,31,40
   end if
   if pItemName is "Battleship" then
      set the cColor of me to 42,42,55
   end if
   if pItemName is "Mushroom" then
      set the cColor of me to 198,198,198
   end if
   if pItemName is "Peach" then
      set the cColor of me to 225,202,202
   end if
   if pItemName is "Mint" then
      set the cColor of me to 225,250,205
   end if
   if pItemName contains "other" then
      set the cColor of me to nameToColor(pItemName)
   end if
   updateSwatches
   send updateOpenScriptEditors to group "Script Editor" of card "Script Editor" of stack "revPreferencesGUI" 
   
   pass menuPick
end menuPick

setProp cColor pColor
   lock messages
   set the cColor of me to pColor
   unlock messages
   
   set the label of me to "tempLabel"
   set the label of me to colorToName(pColor)
end cColor

private function nameToColor pColorName
   switch pColorName
      case "White"
         return "255,255,255"
      break
      case "Custard Yellow"
         return "255,247,215"
      break
      case "Other.."
         # OK-2008-08-01 : Bug 6669 - Need to specify a starting color
         answer color with the cColor of me
         if it is empty then
            return the cColor of me
         else
            return it
         end if
      break
      default
         return "255,255,255"
   end switch
end nameToColor

private function colorToName pColor
   switch pColor
      case "255,247,215"
         return "Custard Yellow"
      break
      case "255,255,255"
         return "White"
      case empty
         return "White"
      break
      default
         return "Other.."
      break
   end switch
end colorToName
