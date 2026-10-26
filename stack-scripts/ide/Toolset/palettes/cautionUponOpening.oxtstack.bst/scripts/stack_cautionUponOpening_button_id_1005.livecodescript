script "stack_cautionUponOpening_button_id_1005"
-- Stack file: ide/Toolset/palettes/cautionUponOpening.oxtstack
-- Object: stack "cautionUponOpening" > card (id 1002) > button "Peek" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   put the cFilename of this stack into tFilepath
   if there is a file (tFilepath) then
      
      open file tFilepath for binary read
      read from file tFilepath until EOF
      put it into tScript
      close file tFilepath
      
      put tScript into fld "theScript" of stack "scriptAlert" of this stack
      open stack "scriptAlert" of this stack
      
   else
      answer error "Sorry, the stack to be checked no longer exists at the expected location." with "Cancel"
   end if
end mouseup
