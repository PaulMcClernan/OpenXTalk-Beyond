script "stack_revOnline_field_id_3623677"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search order" (id 78150) > field "view as" (id 3623677)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mousemove
   lock screen
   local tText
   put the mouseText into tText
   clearColors
   switch tText
      case "List"
         set the textStyle of word 1 of me to "underline"
      break
      case "Grid"
         set the textStyle of word 3 of me to "underline"
      break
   end switch
   unlock screen
end mousemove

on mouseUp
   lock screen
   local tText
   put the mouseText into tText
   if tText is among the items of "List,Grid" then
      clearColors
      switch tText
         case "list"
            updateView "list"
         break
         case "grid"
            updateView "grid"
         break
      end switch
   end if
   unlock screen
end mouseUp

command clearColors
   repeat with x = 1 to the number of words of me
      set the textStyle of word x of me to empty
      set the textColor of word 2 of me to empty
      if word x of me is not the cSelectedView of the owner of me then
         --set the textColor of word x of me to (the foregroundcolor of stack "revonline") 
      end if
   end repeat
end clearColors

on mouseleave
   clearColors
end mouseleave
