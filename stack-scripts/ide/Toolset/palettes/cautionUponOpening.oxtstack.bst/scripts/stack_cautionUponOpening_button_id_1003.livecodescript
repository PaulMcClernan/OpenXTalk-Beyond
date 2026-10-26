script "stack_cautionUponOpening_button_id_1003"
-- Stack file: ide/Toolset/palettes/cautionUponOpening.oxtstack
-- Object: stack "cautionUponOpening" > card (id 1002) > button "Continue to open" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   put the cFilename of this stack into tFilepath
   
   if there is a file (tFilepath) then
      try
         put the long name of this stack into tCloseCautionStackAfter
         open stack (tFilepath)
         if there is a stack (tCloseCautionStackAfter) then close stack (tCloseCautionStackAfter)
      catch e
      end try
   else
      answer error "Sorry, the stack to be opened no longer exists at the expected location." with "Cancel"
   end if
end mouseup
