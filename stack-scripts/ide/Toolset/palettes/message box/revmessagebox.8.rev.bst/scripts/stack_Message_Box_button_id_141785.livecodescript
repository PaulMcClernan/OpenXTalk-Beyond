script "stack_Message_Box_button_id_141785"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Single Line" (id 1002) > group "Stacks" (id 141786) > button "Open Stacks" (id 141785)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown
   local tLabel, tOpenStacks, tFilterStacks
   
   set the opaque of me to true
   global gREVShowStacks
   lock messages
   set the wholeMatches to true
   put the label of me into tLabel
   put the openStacks into tOpenStacks
   put revFilterStacksList(tOpenStacks) into tFilterStacks
   
   switch
      case not gREVShowStacks and tFilterStacks is not empty
         put escapeStackList(tFilterStacks) into me
         break
      case not gREVShowStacks
         put tLabel into me
         break
      case gREVShowStacks
         put escapeStackList(tOpenStacks) into me
         break
   end switch
   
   if tLabel is among the lines of the text of me then set the menuHistory of me to lineOffset(tLabel,tOpenStacks)
   unlock messages 
   pass mouseDown
end mouseDown

on menuPick pItemName
   lock screen
   if pItemName is not empty then
      revIDESetPreference "IDEActiveStack", pItemName
      if revIDEGetPreference("IDELockedToStack") is true
      then revIDESetPreference "IDELinkedToStack", empty
      set the label of me to pItemName
      positionOpenStacksButton
   end if
   unlock screen
end menuPick

on mouseUp
  set the opaque of me to false
end mouseUp

on mouseRelease 
  set the opaque of me to false
end mouseRelease

function escapeStackList pList
   replace "!" with "!!" in pList
   replace "(" with "((" in pList
   replace "&" with "&&" in pList
   return pList
end escapeStackList
