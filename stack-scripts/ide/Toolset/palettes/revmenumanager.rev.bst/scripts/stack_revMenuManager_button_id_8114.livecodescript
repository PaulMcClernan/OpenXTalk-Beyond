script "stack_revMenuManager_button_id_8114"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menubar" (id 3260) > button "Auto Menu Bar Script" (id 8114)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the cAnswerDialog of fld "Menu Name" or the cAnswerDialog of fld "Item Name" then exit mouseUp
   revCheckNameChanged
   if the script of bg id (the cREVMenuID of this stack) of stack (the cREVDefaultStack of this stack) <> empty then
      beep
      answer warning "The menu bar group already has a mouseDown script set.  Overwrite its script?" with "Cancel" or "OK" titled "Auto Menu Bar Script"
      if it = "Cancel" then
         exit to top
      end if
   else
      answer Information "Insert a framework mouseDown handler in the menu bar group's script?" with "Cancel" or "OK" titled "Auto Menu Bar Script"
      if it = "Cancel" then exit to top
   end if
   set the script of bg id (the cREVMenuID of this stack) of stack (the cREVDefaultStack of this stack) to the cMouseDown of me  --custom prop
   if result() <> empty then answer error "Sorry, there was a problem with the menu bar group's script." &cr& result() titled "Error"
   else answer information "Successfully inserted a framework mouseDown handler in the menu bar group's script." with "OK" titled "Auto Menu Bar Script"
   pass mouseUp
end mouseUp
