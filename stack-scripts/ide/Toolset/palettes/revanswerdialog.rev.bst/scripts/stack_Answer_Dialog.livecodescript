script "stack_Answer_Dialog"
-- Stack file: ide/Toolset/palettes/revanswerdialog.rev
-- Object: stack "Answer Dialog"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.



on openStack
   --lock screen
   -- make sure alert window style is correct
   --set the decorations of this wd to "title"
   
   --set the rect of this stack to the left of this stack, the top of this stack, (the right of cd btn id 1240) -10, (the bottom of cd btn id 1240) -10
   --set the itemDelimiter to "," tOldDelim
   --unlock screen
   
   -- reset all custom colour properties
   lock screen
   if there is a cd fld id 1006 of stack "Answer Dialog" then
      set the foregroundColor of this stack to ""
      set the foregroundColor of cd fld id 1006 of stack "Answer Dialog" to ""
      -- default colour text in buttons
      put 0 into tcount
      repeat the number of buttons in stack "Answer Dialog"
         add 1 to tcount
         put the id of btn tcount of stack "Answer Dialog" into tBtnIDtoColour
         set the foregroundColor of btn id tBtnIDtoColour of stack "Answer Dialog" to ""
      end repeat
   end if
   
   
   pass openStack
   
end openStack

